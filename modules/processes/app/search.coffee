text = require "./text"
logger = require "./logger"
_ = require "underscore"
Q = require("q")

class SearchStore extends require("events").EventEmitter
  constructor: (@redis) ->
  update: (searchId,words) ->
    @destroy(searchId).then =>
      @save(searchId,words)
  save: (searchId,words)->
    query = words.sort().join(" ")
    promise = Q.ncall @redis.hset, @redis, "searches", searchId, query
    promise.then @keywordsChanged
    promise
  destroy: (searchId) ->
    promise = Q.ncall @redis.hdel, @redis, "searches", searchId
    promise.then @keywordsChanged
    promise
  all: ->
    Q.ncall @redis.hgetall, @redis, "searches"
  keywordsChanged: =>
    queries = {}
    @redis.hgetall "searches", (err,searches) =>
      for own searchId, query of searches
        queries[query] = true
      @emit "keywordsChanged", Object.keys(queries)

class Search extends require("events").EventEmitter
  constructor: (@redis,@pg,@twitter) ->
    @store = new SearchStore(@redis)
    @store.on "keywordsChanged", (queries) =>
      @emit "keywordsChanged", queries
  updateKeywords: ->
    @store.keywordsChanged()
  create: (searchId,keywordsString) ->
    @store.save(searchId,text.textToKeywords(keywordsString))
    @twitter.search keywordsString, include_entities: "t", (err,result) =>
      result["results"].forEach (tweet) =>
        # tweet IDs are too long for JS, need to use the string everywhere
        tweet.id = tweet.id_str
        # https://dev.twitter.com/docs/api/1/get/search
        # for a joke, the tweet format is totally different in the search than streaming/REST
        tweet.user =
          id_str: tweet.from_user_id_str
          screen_name: tweet.from_user
          profile_image_url_https: tweet.profile_image_url
          name: ""
        @emit "preTrainingMatch", searchId, tweet
  # rails:/app/models/search for format
  update: (searchId,keywordsString) ->
    @store.update(searchId,text.textToKeywords(keywordsString))
  destroy: (searchId) ->
    @store.destroy(searchId)
  tweet: (tweet) ->
    tweetWords = text.tweetToKeywords tweet
    queriesFulfilled = {}
    wordHash = tweetWords.reduce ((hash,word) -> hash[word] = true; hash), {}
    @store.all().then (searches) =>
      for own searchId, query of searches
        if queriesFulfilled[query] || query.split(" ").every((w) -> wordHash[w])
          queriesFulfilled[query] = true
          @emit "match", searchId, tweet

    tweet.text = text.transliterateToUtfBmp(tweet.text)
    @pg.query "INSERT INTO tweets (id, tweet, created_at, updated_at) values ($1, $2, $3, $4)",
              [tweet.id, JSON.stringify(tweet), new Date(Date.parse(tweet.created_at)),new Date],
              (err,result) ->
                logger.error "Error saving tweet #{tweet.id}" if err
                logger.error err

module.exports.Search = Search
