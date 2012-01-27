(function() {
  var AppRouter, Stream, StreamView, Tweet, TweetView,
    __hasProp = Object.prototype.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; },
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __indexOf = Array.prototype.indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; },
    _this = this;

  Tweet = (function(_super) {

    __extends(Tweet, _super);

    function Tweet() {
      Tweet.__super__.constructor.apply(this, arguments);
    }

    Tweet.prototype.url = "/tweets";

    return Tweet;

  })(Backbone.Model);

  Stream = (function(_super) {

    __extends(Stream, _super);

    function Stream() {
      this.initialize = __bind(this.initialize, this);
      Stream.__super__.constructor.apply(this, arguments);
    }

    Stream.prototype.url = "/streams";

    Stream.prototype.initialize = function() {
      return this.set({
        name: "New Search",
        keywords: null,
        tweets: {}
      });
    };

    return Stream;

  })(Backbone.Model);

  TweetView = (function(_super) {

    __extends(TweetView, _super);

    function TweetView() {
      this.markAsIrelevant = __bind(this.markAsIrelevant, this);
      this.markAsRelevant = __bind(this.markAsRelevant, this);
      this.render = __bind(this.render, this);
      this.initialize = __bind(this.initialize, this);
      TweetView.__super__.constructor.apply(this, arguments);
    }

    TweetView.prototype.className = 'tweet';

    TweetView.prototype.tagName = 'li';

    TweetView.prototype.initialize = function() {
      return this.model.bind('change', this.render);
    };

    TweetView.prototype.events = {
      "click .yes": "markAsRelevant",
      "click .no": "markAsIrelevant"
    };

    TweetView.prototype.render = function() {
      var $el, html, id, noBtn, state, text, yesBtn;
      state = this.model.get('state');
      yesBtn = "<a class='button small yes'>Yes</a>";
      noBtn = "<a class='button small no' >No</a>";
      text = (this.model.get('text')).parseURL().parseUsername().parseHashtag();
      html = "" + yesBtn + " " + noBtn + " <span class='text'>" + text + "</span>";
      $el = $(this.el);
      id = this.className + "-" + this.model.id;
      $el.attr({
        "class": this.className + " " + this.model.get('state')
      });
      if ($("#" + id).length === 0) {
        $el.attr({
          id: id
        });
        return $('#tweets').append($el.html(html));
      } else {
        return $el.html(html);
      }
    };

    TweetView.prototype.markAsRelevant = function() {
      return this.model.save({
        state: "relevant"
      });
    };

    TweetView.prototype.markAsIrelevant = function() {
      return this.model.save({
        state: "irelevant"
      });
    };

    return TweetView;

  })(Backbone.View);

  StreamView = (function(_super) {

    __extends(StreamView, _super);

    function StreamView() {
      this.search = __bind(this.search, this);
      this.saveName = __bind(this.saveName, this);
      this.editName = __bind(this.editName, this);
      this.renderTweets = __bind(this.renderTweets, this);
      this.renderKeywords = __bind(this.renderKeywords, this);
      this.renderLink = __bind(this.renderLink, this);
      this.renderName = __bind(this.renderName, this);
      this.render = __bind(this.render, this);
      this.initialize = __bind(this.initialize, this);
      StreamView.__super__.constructor.apply(this, arguments);
    }

    StreamView.prototype.el = "#stream";

    StreamView.prototype.events = {
      "click #name-label": "editName",
      "click #name-container a.button": "saveName",
      "click #search": "search"
    };

    StreamView.prototype.initialize = function() {
      if (!this.model) this.model = new Stream();
      return this.model.bind('change', this.render);
    };

    StreamView.prototype.render = function() {
      this.renderName();
      if (this.model.id) this.renderLink();
      if (this.model.get('keywords')) this.renderKeywords();
      return this.renderTweets();
    };

    StreamView.prototype.renderName = function() {
      var tpl;
      tpl = "<span class='name' id='name-label'>" + (this.model.get('name')) + "</span>";
      return $('#name-container').html(tpl);
    };

    StreamView.prototype.renderLink = function() {
      var html, link;
      link = "http://is.gd/R7dwI0e";
      html = "Bookmark this stream: <a href='" + link + "'>" + link + "</a>";
      return $('#link-container').html(html);
    };

    StreamView.prototype.renderKeywords = function() {
      var $keywords, keyword, keywords, tpl, _i, _len, _results;
      tpl = function(keyword) {
        return "<span class='keyword'>" + keyword + "</span>";
      };
      keywords = (this.model.get('keywords')).split(',');
      $keywords = $('#keywords');
      $keywords.html("");
      _results = [];
      for (_i = 0, _len = keywords.length; _i < _len; _i++) {
        keyword = keywords[_i];
        _results.push($keywords.append(tpl(keyword)));
      }
      return _results;
    };

    StreamView.prototype.renderTweets = function() {
      var tweet, tweets, _i, _len, _results;
      $('#tweets').html("");
      tweets = this.model.get('tweets');
      _results = [];
      for (_i = 0, _len = tweets.length; _i < _len; _i++) {
        tweet = tweets[_i];
        _results.push((new TweetView({
          model: new Tweet(tweet)
        })).render());
      }
      return _results;
    };

    StreamView.prototype.editName = function() {
      var name, tpl;
      name = this.model.get('name');
      tpl = "<input type='text' value='" + name + "'/> <a class='button'>save</a>";
      return $('#name-container').html(tpl);
    };

    StreamView.prototype.saveName = function() {
      var name, tpl;
      name = $('#name-container input').first().val();
      tpl = "<span class='name' id='name-label'>" + name + "</span>";
      $('#name-container').html(tpl);
      return this.model.save({
        name: name
      });
    };

    StreamView.prototype.search = function() {
      var keyword, keywords;
      keyword = $('#search-input').val().trim();
      keywords = this.model.get("keywords");
      if (keywords) {
        keywords = keywords.split();
      } else {
        keywords = [];
      }
      if (keyword === "" || __indexOf.call(keywords, keyword) >= 0) return;
      keywords.push(keyword);
      return this.model.save({
        keywords: keywords.toString()
      });
    };

    return StreamView;

  })(Backbone.View);

  AppRouter = (function(_super) {

    __extends(AppRouter, _super);

    function AppRouter() {
      this.stream = __bind(this.stream, this);
      this["new"] = __bind(this["new"], this);
      AppRouter.__super__.constructor.apply(this, arguments);
    }

    AppRouter.prototype.routes = {
      "": "new",
      "streams/:id": "stream"
    };

    AppRouter.prototype["new"] = function() {
      this.streamView = new StreamView();
      return this.streamView.render();
    };

    AppRouter.prototype.stream = function(id) {
      this.stream = new Stream({
        id: id
      });
      this.streamView = new StreamView({
        model: this.stream
      });
      return this.stream.fetch({
        url: "" + this.stream.url + "/" + id
      });
    };

    return AppRouter;

  })(Backbone.Router);

  $(function() {
    console.log("Welcome to the app!");
    window.app = new AppRouter();
    return Backbone.history.start();
  });

}).call(this);
