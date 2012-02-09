var Search, assert, npromise, redis, tests;

assert = require("assert");

redis = require("redis").createClient();

npromise = require("node-promise");

Search = require("../app/js/search").Search;

assert.sameMembers = function(a, b, message) {
  if (message == null) {
    message = "arrays not equal " + (a.join(" ")) + ",  " + (b.join(" "));
  }
  if (a.length === b.length) {
    return a.every(function(m, i) {
      return b[i] === m;
    });
  } else {
    return false;
  }
};

tests = [
  function() {
    var search;
    search = new Search({
      hgetall: function(key, cb) {
        return cb(null, {
          "foo": 1
        });
      }
    }, {
      query: function() {}
    });
    search.on("keywordsChanged", function(keywords) {
      return assert.deepEqual(["foo"], keywords, "emits keywords");
    });
    return search.updateKeywords();
  }, function() {
    var expected, search, testSearchCreated;
    search = new Search(redis, {
      query: function() {}
    });
    search.update({
      id: 15,
      changed: {
        keywords: "foo, bar, baz"
      }
    });
    expected = ["foo", "bar", "baz"];
    testSearchCreated = function() {
      redis.get("searches:15", function(err, search) {
        return assert.sameMembers(expected, JSON.parse(search).or);
      });
      return redis.sismember("searches", 15, function(err, member) {
        return assert(member, "should be recorded as search");
      });
    };
    return search.on("keywordsChanged", function(keywords) {
      assert.sameMembers(expected, keywords, "stores keywords");
      return testSearchCreated();
    });
  }, function(promise) {
    var matched, search, stored;
    stored = false;
    matched = false;
    search = new Search(redis, {
      query: function() {
        return stored = true;
      }
    });
    search.update({
      id: 15,
      changed: {
        keywords: "foo"
      }
    });
    search.on("match", function(id, tweet) {
      return promise.resolve();
    });
    setTimeout(function() {
      search.tweet({
        text: "foo",
        entities: {},
        user: {}
      });
      return assert(stored, "stores in db");
    }, 100);
    return promise;
  }
];

tests.forEach(function(t) {
  var deferred, passed, promise;
  promise = new npromise.Promise;
  deferred = t(promise);
  if (deferred.then) {
    passed = false;
    deferred.then(function() {
      return passed = true;
    });
    return setTimeout(function() {
      if (!passed) assert(false, "test not passed, " + t);
      return redis.flushall();
    }, 500);
  } else {
    return redis.flushall();
  }
});

console.log(tests.length + " tests started");
