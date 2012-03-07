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

    @set streams:streams
    @set user:user
    user.login()

    tutorialState = user.get("tutorialState") ||0 

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
    if @isNew() then @on "change:id", @subscribe
    else @subscribe()

    @keywords = new (Collection.extend model: Model.extend(idAttribute: "word"))
    @keywords.on "add", @saveKeywords
    @keywords.on "remove", @saveKeywords
    @keywords.reset (@get('keywords') or "")
      .split(",")
      .map((w) -> w.trim())
      .filter((w) -> w != "")
      .map((w) -> word: w)

  saveKeywords: => 
    @save keywords: @keywords.pluck("word").join(", ") 

  getKeywords: =>
    @keywords.pluck "word"

  subscribe: =>

    PUBNUB?.subscribe
      channel: "search:#{@id}:tweets:add"
      callback: (message) =>
        message = camelize message
        unless @tweetsCollection.get message.tweet.id
          @tweetsCollection.add message.tweet

  addKeywords: (words) =>
    return false if typeof words isnt "object" or words.length is 0
    @keywords.add words
      .map((w) => w.trim())
      .filter((w) => w != "" and not @keywords.get w)
      .map((w) -> word:w)
    true

  removeKeyword: (word) =>
    @keywords.remove(word)

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

  initialize: =>

    @set tutorialState: parseInt(localStorage.tutorialState || 0)
    @on "change:tutorialState", (user,state) ->
      localStorage.tutorialState = state

  url: "/users"

  login: (opts = {}) => 
    opts.url = "/users/me"
    @fetch _.extend opts,
      success: => @trigger "login"
      error: => @trigger "needs-login"

  loginAs: (user) =>
    @set user
    @trigger "login"


class TweetsView extends View
  
  initialize: =>
    @renderQueue = []
    @queuePaused = false
    @collection.on 'add', @addToQueue
    @render()
    @$el
      .mouseenter(=> @queuePaused = true)
      .mouseleave(=> @queuePaused = false)

    setInterval @renderFromQueue, 500

  addToQueue: (tweet) => @renderQueue.unshift tweet

  render: =>
    if @collection.length > 0 then @$el.html ""
    @collection.each (tweet) => @renderTweet tweet, false

  renderFromQueue: =>
    if @renderQueue.length > 0 and not @queuePaused
      @renderTweet @renderQueue.pop(), true

  renderTweet: (tweet, slideIn) =>

    tweetView = new TweetView
      model: tweet

    if not @$el.find(tweetView.el).length
      @$el.prepend tweetView.el
      if slideIn
        h = tweetView.$el.height() 
        tweetView.$el.css "margin-top": "#{-h}px"
        tweetView.$el.show().animate("margin-top": "0px", duration:500)

CATEGORY_BORING = "boring"
CATEGORY_INTERESTING = "interesting"

class TweetView extends View

  tagName: "article"
  className: "tweet"

  events:
    "click .yes": "markAsRelevant"
    "click .no": "markAsIrrelevant"

  initialize: =>
    @model.on 'change:id', @render
    @model.on 'change:category', @renderCategory
    @$el.mouseenter(@showActions).mouseleave(@hideActions)
    @render()

  render: =>
    @$el.html _.template Templates.tweet, @model.toJSON() 
    @$('.time-ago').timeago()
    @renderCategory() 

  renderCategory: (model, cat) =>
    model = model or @model
    cat = cat or @model.get 'category'
    if cat is CATEGORY_BORING and @model.hasChanged 'category'
      @$el.css height: 'auto'
    prevCat = @model.previous 'category'
    if prevCat? then @$el.removeClass prevCat
    @$el.addClass cat

  markAsRelevant: => 
    @changeState CATEGORY_INTERESTING 

  markAsIrrelevant: => 
    @changeState CATEGORY_BORING 

  changeState: (newCat) =>
    cat = @model.get 'category'
    if cat isnt newCat
      console.log newCat
      @model.save category:newCat

  showActions: =>
    @$('.time-ago').toggleClass "hidden", true
    @$('.actions').toggleClass "hidden", false

  hideActions: =>
    @$('.time-ago').toggleClass "hidden", false
    @$('.actions').toggleClass "hidden", true

class StreamsView extends View

  el: "#streams"

  events:
    "submit .create-stream": "createStream"
    "click .next": "tutorialNext"

  initialize: ({@user,@app}) =>
    @collection.bind 'add', @renderStream
    @collection.bind "add remove", @renderControl
    @collection.bind 'reset', @render
    @app.bind "change:loaded", =>
      @$(".loading").remove()
      @renderControl()
    @user.bind "change:tutorialState", @renderControl

  render: =>
    @collection.each @renderStream
    @renderControl()

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
    streamView.adjustSettingsSize()

  tutorialNext: ->
    @user.set tutorialState: (@user.get("tutorialState") || 0) + 1
  createStream: =>
    if @app.canMakeStream()
      @app.get('streams').create {keywords: @$("input.keywords").val()}, {wait:true}
    else
      alert("Sorry, you can only create #{@app.maxStreams} streams")
    false

class StreamView extends View

  tagName  : "article"
  className: "stream"

  events:
    'click  .stream.closed .stream-header': 'toggleSettings'
    'click  .stream.open .toggle-settings': 'toggleSettings'
    'click  .settings .done:'             : 'toggleSettings'
    'submit .add-keyword-form': 'addKeyword'
    'click  .add-keyword'     : 'addKeyword'
    'click  .remove-keyword'  : 'removeKeyword'
    'click  .remove-stream'   : 'removeStream'

  initialize: =>  
    @settingsOpen = false
    @$el.addClass "closed"
    @$el.attr 'id', "stream-#{@model.id}"
    @model.on 'change:keywords', @renderKeywords
    @render()

  render: =>
    @$el.html _.template Templates.stream, @model.toJSON()
    @renderTitle()
    @renderKeywords()
    @renderTweets() 

  renderTitle: =>
    words = @model.getKeywords()  
    if words.length is 0
      title = "Add keywords here..."
      @$el.addClass "no-keywords"
    else
      @$el.removeClass "no-keywords"
      title = words.join(', ')
      if title.length > 22 then title = title.slice(0,22) + '...'
    @$('.stream-title').html title
  
  renderKeywords: =>
    $keywords = @$('.keywords')
    $keywords.html ""
    @model.getKeywords().map (w) => 
      $keywords.append _.template Templates.keywords, {word:w}
    @adjustSettingsSize()
     
  editKeywords: =>
    @$('.stream-title').html _.template Templates.editKeywords
    @$('.add-keyword-form input').focus()

  addKeyword: (evt) =>
    $input = @$('.add-keyword-form input')
    if @model.addKeywords $input.val().trim().split(',')
      $input.val('')
    false

  removeKeyword: (evt) ->
    word = $(evt.currentTarget).parent().find('.word').html().trim()
    @model.removeKeyword(word)
           
  toggleSettings: =>
    if @settingsOpen 
      @settingsOpen = false
      @$el.addClass "closed"
      @$el.removeClass "open"
      move("##{@$el.attr 'id'} .toggle-settings").rotate(-45).end()
      @renderTitle()
    else
      @settingsOpen = true
      @$el.addClass "open"
      @$el.removeClass "closed"
      move("##{@$el.attr 'id'} .toggle-settings").rotate(45).end()
      @editKeywords()
    @$('.settings').toggle()
    @adjustSettingsSize()

  adjustSettingsSize: =>
    if (@$('.settings').css 'display') is 'none'
      @$('.tweets').animate top: 51, 50
      @$('.stream-header').animate height: '44px', 50
    else 
      h = 60 + parseInt @$('.settings').css('height').replace('px', '')
      @$('.tweets').animate top: 10+h, 50
      @$('.stream-header').animate height: "#{h}px", 50

  removeStream: =>
    @model.destroy() 

  renderTweets: =>
    new TweetsView
      collection: @model.tweetsCollection
      el: @$(".tweets")[0]

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

$ ->
  authenticityToken = $("[name=csrf-token]").attr("content")
  window.app = app = new App()
  window.appView = appView = new AppView model:app
  console.log ":o::> Teach the Bird! <::o:"
