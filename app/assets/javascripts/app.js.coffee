//= require jquery.min
//= require underscore.min
//= require backbone.min
//= require tweets
//= require tweet-parsers

//= require templates

//= require sinon
//= require fake_server

# TODO use twitter anywhere to add hovercard, webintents. Web intents can make replying etc look v nice

class App extends Backbone.Model

    initialize: =>
        _.extend @, Backbone.Events

    login: =>
        # fake it for now
        streams = new Streams()
        user = new User
        user.fetch
          url: "/users/me"
          success: =>
            streams.fetch()
            @trigger "login"
          error: ->
            @trigger "needs-login"

        @set streams:streams
        @set user:user

class Tweet extends Backbone.Model
class Tweets extends Backbone.Collection
    model: Tweet
    url: "/tweets"

class Stream extends Backbone.Model
class Streams extends Backbone.Collection
    initialize: ->
      # TODO connect to pusher, add new tweets to connection
    model: Stream
    url: "/streams"


class User extends Backbone.Model
    url: "/users"

class TweetsView extends Backbone.View

    initialize: =>
        @collection.bind 'add', @renderTweet

    render: =>
        if @collection.models.length > 0 then @$el.html ""
        @collection.each (tweet) => @renderTweet tweet

    renderTweet: (tweet) =>
        tweetView = new TweetView
            model: tweet
            parentId:@options.parentId
            parentEl:@el
        tweetView.render()

class TweetView extends Backbone.View

    tagName: "article"
    className: "tweet"

    events:
        "click .yes": "markAsRelevant"
        "click .no": "markAsIrelevant"

    initialize: =>
        @$el.attr 'id', "tweet-#{@options.parentId}-#{@model.id}"
        @model.bind 'change', @render

    render: =>
        @$el.html _.template Templates.tweet, @model.toJSON()
        if $('#'+@$el.attr 'id').length is 0
            $(@options.parentEl).prepend @el

    markAsRelevant: =>
        # TODO it's best to always update the view as the model is updated, not in view commands
        # for instance, if the server sends us an update on the relevant state
        # it won't be handelled. If it was written as @model.on "change:relevency", -> etc it would
        # handle both cases
        @$el.addClass "relevant"
        @model.save state: "relevant"
    markAsIrelevant: =>
        @$el.addClass "irelevant"
        @model.save state: "irelevant"

class StreamsView extends Backbone.View

    el: "#streams"

    initialize: =>
        @collection.bind 'add', @renderStream
        @collection.bind 'reset', @render

    render: =>
        @collection.each (stream) =>
            @renderStream stream

    renderStream: (stream) =>
        streamView = new StreamView {model: stream}
        streamView.render()

class StreamView extends Backbone.View

    tagName: "article"
    className: "stream"

    events:
        'click .settings-btn': 'settings'
        'click .search-btn': 'addKeyword'

    initialize: =>
        @$el.attr 'id', "stream-#{@model.id or @model.cid}"
        @model.on 'change', @change

    change: =>
        if @model.hasChanged 'keywords' then @renderKeywords()

    render: =>
        @$el.html _.template Templates.stream, @model.toJSON()
        $('#streams').append @el
        @renderTweets()
        if @model.get 'keywords' then @renderKeywords()

    renderTweets: =>
        tweets = new Tweets @model.get 'tweets'
        tweetsView = new TweetsView
            collection:tweets
            el:"#tweets-#{@model.id}"
            parentId:@model.id
        tweetsView.render()

    renderKeywords: =>
        tpl = (keyword) ->
            "<span class='keyword'>#{keyword} <span class='del'>x</span></span>"
        keywords = (@model.get 'keywords').split ','
        $keywords = @$el.find('.keywords')
        $keywords.html ""
        $keywords.append tpl keyword for keyword in keywords

    settings: (e) =>
        $settings = $(e.target).parent().find('.settings').first()
        $settings.toggle()
        if ($settings.css 'display') is 'none'
            @$el.find('.tweets').css 'top', '51'
            @$el.find('.stream-header').css 'height', '44px'
        else
            @$el.find('.tweets').css 'top', '201'
            @$el.find('.stream-header').css 'height', '194px'

    addKeyword: =>
        keyword = @$el.find('.search-input').val().trim()
        keywords = @model.get "keywords"
        if keywords then keywords = keywords.split() else keywords = []
        return if keyword is "" or keyword in keywords
        keywords.push keyword
        @model.save {keywords: keywords.toString()}
        @$el.find('.search-input').val("")

     delKeyword: (e) =>

#
# User view
class UserView extends Backbone.View

    el: "#user"

    initialize: =>
        @model.bind 'change', @render

    render: =>
        $('.user-name').html @model.get 'name'

#
# App view
class AppView extends Backbone.View

    el: "#app"

    initialize: =>
        @model.on 'login', @login

    events:
        "click #new-stream-btn": "newStream"

    login: =>
        new UserView model:@model.get 'user'
        new StreamsView collection:@model.get 'streams'
        @render()

    render: =>
        @showApp()
        @hideSplash()

    showApp: => $('#app').css "display", "block"
    hideSplash: => $('#splash').css "display", "none"

    newStream: =>
        (@model.get 'streams').create {name:'New Stream'}, {wait:true}

class AppRouter extends Backbone.Router

    routes:
        "login" : "login"

    login: =>
        app = new App()
        appView = new AppView model:app
        app.login()

$ =>
    console.log ":o::> Teach the Bird! <::o:"
    router = new AppRouter()
    Backbone.history.start()
