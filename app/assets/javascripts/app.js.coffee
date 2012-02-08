//= require jquery.min
//= require jquery.timeago.js
//= require underscore.min
//= require backbone.min
//= require tweets
//= require tweet-parsers

//= require templates

# TODO use twitter anywhere to add hovercard, webintents. Web intents can make replying etc look v nice
{Model,View,Collection,Router,Events} = Backbone

window.authorised = (user) ->
  window.app.get("user").loginAs(user)


class App extends Model
    initialize: ->
      streams = new Streams()
      user = new User
      user.on "login", ->
        streams.fetch()

      @set streams:streams
      @set user:user
      user.login()

class Tweet extends Model
class Tweets extends Collection
    model: Tweet
    url: "/tweets"

class Stream extends Model
    initialize: ->
      PUBNUB.subscribe
        channel: "search:#{@id}:tweets:add"
        callback: (message) =>
          @add message.tweet

class Streams extends Collection
    model: Stream
    url: "/streams"
    fetch: (opts = {}) ->
      opts.url = "/streams/mine"
      Collection::fetch.call this, opts

class User extends Model
    url: "/users"
    login: (opts = {}) ->
      opts.url = "/users/me"
      @fetch _.extend opts,
        success: =>
          @trigger "login"
        error: =>
          @trigger "needs-login"
    loginAs: (user) ->
      @set user
      @trigger "login"

class TweetsView extends View

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

class TweetView extends View

    tagName: "article"
    className: "tweet"

    events:
        "click .yes": "markAsRelevant"
        "click .no": "markAsIrrelevant"

    initialize: =>
        @$el.attr 'id', "tweet-#{@options.parentId}-#{@model.id}"
        @model.on 'change', @render
        @$el.mouseenter(@showActions).mouseleave(@hideActions)
  
    render: =>
        @$el.attr 'class', "#{@className} #{@model.get 'state'}"
        @$el.html _.template Templates.tweet, @model.toJSON() 
        if $("##{@$el.attr 'id'}").length is 0
            $(@options.parentEl).prepend @el
        @$('.time-ago').timeago()

    markAsRelevant: => 
        @changeState "relevant" 
    
    markAsIrrelevant: => 
        @changeState "irrelevant" 
    
    changeState: (state) =>
        (@model.save state:state) if (@model.get 'state') isnt state

    showActions: =>
        @$('.time-ago').css 'display', 'none'
        @$('.actions').css 'display', 'block'

    hideActions: =>
        @$('.time-ago').css 'display', 'block'
        @$('.actions').css 'display', 'none'

class StreamsView extends View

    el: "#streams"

    initialize: =>
        @collection.bind 'add', @renderStream
        @collection.bind 'reset', @render
        @render()
    render: =>
        @collection.each @renderStream
    renderStream: (stream) =>
        streamView = new StreamView {model: stream}
        streamView.render()

class StreamView extends View

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

class UserView extends View

    el: "#user"

    initialize: =>
        @model.bind 'change', @render

    render: =>
        $('.user-name').html @model.get 'name'

class AppView extends View

    el: "#app"

    initialize: =>
        new UserView model:@model.get 'user'
        new StreamsView collection:@model.get 'streams'

    events:
        "click #new-stream-btn": "newStream"

    newStream: =>
        @model.get('streams').create {name:'New Stream'}, {wait:true}

window.app = app = new App()
$ ->
    window.appView = appView = new AppView model:app
    console.log ":o::> Teach the Bird! <::o:"
