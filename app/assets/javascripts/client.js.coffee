# TODO use twitter anywhere to add hovercard, webintents. Web intents can make replying etc look v nice
{Model,View,Collection,Router,Events} = Backbone

MAX_STREAMS = 3

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

getValue = (object, prop) ->
  return null unless object && object[prop]
  if _.isFunction(object[prop]) then object[prop]() else object[prop]

Model::sync = Collection::sync = sync = (method,model,options = {}) ->

  type = methodMap[method]

  params = _.extend
    type: type
    dataType: "json"
  , options

  params.url = getValue(model,'url') unless params.url
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
      user.on "login", =>
        streams.fetch
          success: =>
            @set loaded: true
          add: true

      @set streams:streams
      @set user:user
      user.login()

      tutorialState = user.get("tutorialState") || 0
      if tutorialState == 0
        streams.on "add", ->
          user.set tutorialState: 1
      if tutorialState < 1
        streams.on "change:state", ->
          user.set tutorialState: 2
    maxStreams: 3
    canMakeStream: ->
      @get('streams').length < @maxStreams

class Tweet extends Model
class Tweets extends Collection
    model: Tweet
    url: "/tweets"

class Stream extends Model
    initialize: =>
        
        @tweetsCollection = new Tweets @get 'tweets'
        
        # Testing code (to be removed) 
        ###
        if @id is 123
            window.setInterval( =>
                window.push_tweet.id = "#{parseInt(Math.random()*100)}" 
                @tweetsCollection.add camelize window.push_tweet
            , 
                5000
            )
        ###
        PUBNUB?.subscribe
            channel: "search:#{@id}:tweets:add"
            callback: (message) =>
                return if @tweetsCollection.get message.tweet.id
                message = camelize message
                @tweetsCollection.add message.tweet
 
        @keywordCollection = new (Collection.extend
            model: Model.extend(idAttribute: "word")
        )
        @keywordCollection.on "add", @syncKeywords
        @keywordCollection.on "remove", @syncKeywords
        @keywordCollection.reset (@get('keywords') || "").split(",").map((w) -> w.trim()).filter((w) ->w != "").map((w) -> {word: w})
    
    syncKeywords: => 
        @save {keywords: @keywordCollection.pluck("word").join(", ")} 
    keywords: =>
        @keywordCollection.pluck("word")
    addKeyword: (keyword) =>
        return false if keyword is "" or @keywordCollection.get(keyword)
        @keywordCollection.add word: keyword
        true
    removeKeyword: (keyword) =>
        @keywordCollection.remove(keyword)

class Streams extends Collection
    model: Stream
    url: "/streams"
    fetch: (opts = {}) ->
      opts.url = "/streams/mine"
      Collection::fetch.call this, opts

TUTORIAL_CREATE = 0
TUTORIAL_CLASSIFY = 1
TUTORIAL_SHARE = 2
TUTORIAL_FINISHED = 3
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
        @render()

    render: =>
        if @collection.length > 0 then @$el.html ""
        @collection.each @renderTweet

    renderTweet: (tweet) =>
        new TweetView
            model: tweet
            parentEl:@el

class TweetView extends View

    tagName: "article"
    className: "tweet"

    events:
        "click .yes": "markAsRelevant"
        "click .no": "markAsIrrelevant"

    initialize: =>
        @$el.attr 'id', "tweet-#{@model.id}"
        @model.on 'change:id', @render
        @model.on 'change:category', @renderCategory
        @$el.mouseenter(@showActions).mouseleave(@hideActions)
        @render()
  
    render: =>
        @renderCategory() if @model.get 'category'              
        @$el.html _.template Templates.tweet, @model.toJSON() 
        if $("##{@$el.attr 'id'}").length is 0 
            $(@options.parentEl).prepend @el
            move(@el).scale(0).duration(100).then(=> move(@el).scale(1).end()).end()      
            @$('.time-ago').timeago()
       
    renderCategory: =>
        cat = @model.get 'category'
        if cat is 'boring' and @model.hasChanged 'category' 
            move(@el).scale(0).ease('snap').duration(350)
            .end => @$el.attr 'class', "#{@className} #{cat}"
        else
            @$el.attr 'class', "#{@className} #{cat}"

    markAsRelevant: => 
        @changeState "interesting"
    
    markAsIrrelevant: => 
        @changeState "boring"
    
    changeState: (state) =>
        (@model.save category:state) if (@model.get 'category') isnt state

    showActions: =>
        @$('.time-ago').css 'display', 'none'
        @$('.actions').css 'display', 'block'

    hideActions: =>
        @$('.time-ago').css 'display', 'block'
        @$('.actions').css 'display', 'none'

class StreamsView extends View

    el: "#streams"

    events:
      "submit .create-stream": "createStream"
      "click .next": "tutorialNext"

    initialize: ({@user,@app}) =>
        @collection.bind 'add', @renderStream
        @collection.bind "add remove reset", @renderControl
        @app.bind "change:loaded", =>
          @$(".loading").remove()
          @renderControl()
        @user.bind "change:tutorialState", @renderControl

    renderControl: =>
        @controlEl?.remove()
        if @collection.length < MAX_STREAMS
          @controlEl = $("<div class='control'><div class='content'>#{Templates.tutorials[@user.get("tutorialState") || 0]}</div></div>")
          @$el.append @controlEl

    renderStream: (stream) =>
        streamView = new StreamView {model: stream}
        stream.on "destroy", ->
          streamView.$el.remove()
        @$el.append streamView.el

    tutorialNext: ->
      @user.set tutorialState: (@user.get("tutorialState") || 0) + 1

    createStream: =>
      if @app.canMakeStream()
        @app.get('streams').create {name:'New Stream'}, {wait:true}
      else
        alert("Sorry, you can only create #{@app.maxStreams} streams")
      false

class StreamView extends View

    tagName: "article"
    className: "stream"

    events:
        'click .name': 'editName'
        'submit .edit-name-form': 'saveName'
        'click .edit-name': 'editName'
        'click .save-name': 'saveName'
        'click .delete-zone': 'deleteStream'
        'click .settings-btn': 'toggleSettings'
        'click .search-btn': 'addKeyword'
        'click .del': 'removeKeyword'


    initialize: =>
        @editingName = false
        @$el.attr 'id', "stream-#{@model.id or @model.cid}"
        @model.on 'change:keywords', @renderKeywords
        @model.on 'change:name', @renderName
        @render()

    render: =>
        @$el.html _.template Templates.stream, @model.toJSON()
        @renderTweets()
        @renderKeywords()

    renderTweets: =>
        new TweetsView
            collection: @model.tweetsCollection
            el: @$(".tweets")[0]

    renderName: =>
        @editingName = false
        @$('h1.name').html @model.get 'name'
        @$('.save-name').css 'display', 'none'
        
    editName: =>
        return if @editingName
        @editingName = true  
        tpl = (name) -> 
            "<form class='edit-name-form'><input type='text' value='#{name}'/></span></form>"
        @$('.name').html tpl(@model.get 'name')
        @$('.edit-name').css 'display', 'none'
        @$('.save-name').css 'display', 'inline-block'
        @$('.name input').focus()

    saveName: (evt)=>
        @model.save name: @$('.name input').val().trim()
        @$('.edit-name').css 'display', 'inline-block'
        @model.trigger 'change:name'
        false
             
    renderKeywords: =>
        tpl = (keyword) ->
            "<span class='keyword'><span class='word'>#{keyword}</span>
             <span class='del'>x</span></span>"
        $keywords = @$('.keywords')
        $keywords.html ""
        $keywords.append tpl keyword for keyword in @model.keywords()
        @adjustSettingsSize()

    toggleSettings: =>
        @$('.settings').toggle()
        @adjustSettingsSize()

    adjustSettingsSize: =>
        if (@$('.settings').css 'display') is 'none'
            @$('.tweets').css 'top', '51'
            @$('.stream-header').css 'height', '44px'
        else 
            h = 60 + parseInt @$('.settings').css('height').replace('px', '')
            @$('.tweets').css 'top', "#{10+h}"
            @$('.stream-header').css 'height', "#{h}px"
    
    addKeyword: =>
        $input = @$('.search-input')
        keyword = $input.val().trim()
        if @model.addKeyword keyword
            $input.val("")

    removeKeyword: (evt) ->
        word = $(evt.currentTarget).parent().find('.word').html().trim()
        @model.removeKeyword(word)

    deleteStream: =>
      @model.destroy()

class UserView extends View

    el: "#user"

    initialize: =>
        @model.on 'change', @render

    render: =>
        $('.user-name').html @model.get 'name'

class AppView extends View

    el: "#app"

    initialize: =>
        new UserView model:@model.get 'user'
        new StreamsView
          collection:@model.get 'streams'
          user: @model.get 'user'
          app: @model
        twttr.anywhere (T) ->
            T.hovercards("#streams")
            T.linkifyUsers("#streams")
            T(".profile_image").hovercards username: (node) -> node.alt

$ ->
  authenticityToken = $("[name=csrf-token]").attr("content")
  window.app = app = new App()
  window.appView = appView = new AppView model:app
  console.log ":o::> Teach the Bird! <::o:"
