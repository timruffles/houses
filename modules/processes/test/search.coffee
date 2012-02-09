assert = require "assert"
redis = require("redis").createClient()
npromise = require "node-promise"
Search  = require("../app/js/search").Search


assert.sameMembers = (a,b,message = "arrays not equal #{a.join(" ")},
  #{b.join(" ")}") ->
  if a.length == b.length
    a.every (m,i) -> b[i] == m
  else
    false


tests = [
  ->
    search = new Search({
      hgetall: (key, cb) ->
        cb(null,{"foo":1})
    },{query: ->})
    search.on "keywordsChanged", (keywords) ->
      assert.deepEqual ["foo"], keywords, "emits keywords"
    search.updateKeywords()
  ->
    search = new Search(redis,{query: ->})
    search.update
      id: 15
      changed:
        keywords: "foo, bar, baz"
    expected = ["foo","bar","baz"]
    testSearchCreated = ->
      redis.get "searches:15", (err,search) ->
        assert.sameMembers expected, JSON.parse(search).or
      redis.sismember "searches", 15, (err,member) ->
        assert member, "should be recorded as search"
    search.on "keywordsChanged", (keywords) ->
      assert.sameMembers expected, keywords, "stores keywords"
      testSearchCreated()
  (promise) ->
    stored = false
    matched = false
    search = new Search(redis,{query: ->
      stored = true})
    search.update
      id: 15
      changed:
        keywords: "foo"
    search.on "match", (id, tweet) ->
      promise.resolve()
    setTimeout ->
      search.tweet
        text: "foo"
        entities: {}
        user: {}
      assert stored, "stores in db"
    , 100
    promise
]


tests.forEach (t) ->
  promise = new npromise.Promise
  deferred = t(promise)
  if deferred.then
    passed = false
    deferred.then ->
      passed = true
    setTimeout ->
      assert false, "test not passed, #{t}" unless passed
      redis.flushall()
    , 500
  else
    redis.flushall()


console.log(tests.length + " tests started")

