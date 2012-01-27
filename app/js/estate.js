(function() {
  var apiUrl, examples, json200, postBody, responses, server, setup,
    _this = this;

  server = sinon.fakeServer.create();

  server.autoRespond = true;

  server.fakeHTTPMethods = true;

  server.autoRespondAfter = 800;

  json200 = function(xhr, response) {
    var array;
    array = response.responseArray || [
      200, {
        "Content-Type": "application/json"
      }, JSON.stringify(response)
    ];
    return xhr.respond.apply(xhr, array);
  };

  apiUrl = function(url) {
    return new RegExp(("^" + url).replace(/:id/g, "(\\d+)"));
  };

  postBody = function(xhr) {
    return JSON.parse(xhr.requestBody);
  };

  responses = {
    stream: function(id) {
      return {
        name: "Evil estate agent house search",
        keywords: "house hunting, I need flat, give me flat, OH GOD FLATS",
        id: "123",
        tweets: tweets
      };
    },
    streamCreate: function(xhr) {
      var stream;
      console.log('creating....');
      stream = postBody(xhr);
      stream.id = "apoapiw";
      stream.tweets = tweets;
      return stream;
    },
    streamUpdate: function(xhr) {
      console.log('updating...');
      return postBody(xhr);
    },
    tweetUpdate: function(xhr) {
      return postBody(xhr);
    }
  };

  examples = [];

  setup = function(method, url, handler, exampleData) {
    server.respondWith(method, url, handler);
    return examples.push(arguments);
  };

  setup("GET", apiUrl("/streams/(\\w+)"), function(xhr, id) {
    return json200(xhr, responses.stream(id));
  });

  setup("POST", apiUrl("/streams"), function(xhr) {
    return json200(xhr, responses.streamCreate(xhr));
  }, {
    name: "Evil estate agent house search",
    keywords: "house hunting, I need flat, give me flat, OH GOD FLATS"
  });

  setup("PUT", apiUrl("/streams"), function(xhr) {
    return json200(xhr, responses.streamUpdate(xhr));
  }, {
    id: "areafprogksrigjosijfoisjr",
    keywords: "new list of keywords"
  });

  setup("PUT", apiUrl("/tweets"), function(xhr) {
    return json200(xhr, responses.tweetUpdate(xhr));
  }, {
    id: "141522834898960384",
    done: true,
    state: "relevent"
  });

  examples.forEach(function(_arg) {
    var exampleData, handler, method, url;
    method = _arg[0], url = _arg[1], handler = _arg[2], exampleData = _arg[3];
    url = url.toString().replace("/^", "").replace("(\\w+)", "areafprogksrigjosijfoisjr").replace(/\/$/, "");
    return $.ajax({
      url: url,
      data: exampleData ? JSON.stringify(exampleData) : null,
      dataType: "json",
      contentType: 'application/json',
      type: method,
      success: function(resp) {
        return console.log("" + method + " to " + url + ", response:", resp);
      }
    });
  });

}).call(this);
