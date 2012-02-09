brain = require("brain")
stemmer = require("./libs/stemmer").stemmer
text = require("./text")
logger = require("./logger")
# ## User updates
Classifier = class Classifier extends require("events").EventEmitter

  this.INTERESTING = INTERESTING = "interesting"
  this.BORING = BORING = "boring"
  this.UNSEEN = UNSEEN = "unseen"

  constructor: (@pg) ->
  getBayes: (searchId) ->
    new brain.BayesianClassifier
      backend :
        type: 'redis'
        options:
          hostname: 'localhost'
          port: 6379
          # namespace so you can persist training
          name: "tweet_classifications:#{searchId}"
      thresholds:
        boring: 1
        interesting: 3
      # category if can't classify
      def: INTERESTING

  classificationString: (tweet) ->
    text.tweetToKeywords(tweet).map((word) ->
      stemmer(word)
    ).join(" ")

  train: (searchId,tweet,category) ->
    console.log("train on ",@classificationString(tweet))
    @getBayes(searchId).train(@classificationString(tweet),category)

  classify: (searchId, tweet) ->
    classifiedEvents = this
    pg = @pg
    @getBayes(searchId).classify @classificationString(tweet), (category) ->
      logger.debug "classified #{tweet.id} as #{category}"
      tweet.category = category
      classifiedEvents.emit "classified", searchId, tweet, category
      # store the tweet's classification for if user isn't online right now
      pg.query "INSERT INTO classified_tweets (search_id, tweet_id, category) VALUES ($1, $2, $3)", [searchId, tweet.id, category]
  classifyAs: (searchId,tweet,category) ->
    @pg.query "INSERT INTO classified_tweets (search_id, tweet_id, category) VALUES ($1, $2, $3)", [searchId, tweet.id, category]
    @emit "classified", searchId, tweet, category

module.exports.Classifier = Classifier
