//= require jquery.min
//= require jquery.timeago.js
//= require underscore.min
//= require core_ext
//= require backbone.min
//= require tweets
//= require tweet-parsers
//= require templates
#//= require sinon
#//= require fake_server

# TODO use twitter anywhere to add hovercard, webintents. Web intents can make replying etc look v nice
{Model,View,Collection,Router,Events} = Backbone

window.authorised = (user) ->
  window.app.get("user").loginAs(user)

authenticityToken = false

methodMap =
  create: "POST"
  update: "PUT"
  delete: "DELETE"
  read: "GET"

 transformKeys = (stringTransform) ->
    transformer = (obj) ->
      image = {}
      if typeof obj == "object"
        if _.isArray(obj)
          return _.map obj, (mem) -> transformer(mem)
        for own key, val of obj
          # remember typeof null === "object". lulz ensue
          val = if _.isArray val
                  _.map val, transformer
                else
                  if val? and typeof val is "object" then transformer(val) else val
          image[key[stringTransform]()] = val
        image
      else
        obj

camelize = transformKeys("camelize")

underscore = transformKeys("underscore")

Model::sync = Collection::sync = sync = (method,model,options = {}) ->

  type = methodMap[method]

  params = _.extend
    type: type
    dataType: "json"
  , options

  params.url = getUrl(method,model,params) unless params.url
  params.url += ".json"

  switch method
    when "create","update","delete"
      params.headers ||= {}
      params.headers["X-CSRF-Token"] = authenticityToken
  switch method
    when "create", "update"
      params.data = JSON.stringify underscore model.toJSON()
      params.contentType = "application/json"

  {success,error} = params
  params.success = (resp,status,xhr) ->
    console.log "http response", resp, params
    if success
      # don't pass through HTTP implementation details to model layer
      success camelize(resp), status, xhr
  params.error = ->
    console.log "http error resp", arguments
    error(arguments...) if error

  params.processData = false if params.type isnt "GET" and not Backbone.emulateJSON
  $.ajax params



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
      PUBNUB?.subscribe
        channel: "search:#{@id}:tweets:add"
        callback: (message) =>
          message = camelize message
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

$ ->
  authenticityToken = $("[name=csrf-token]").attr("content")
  window.app = app = new App()
  window.appView = appView = new AppView model:app
  console.log ":o::> Teach the Bird! <::o:"
