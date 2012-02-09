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
      user.on "login", ->
        streams.fetch()

      @set streams:streams
      @set user:user
      user.login()
    maxStreams: 3
    canMakeStream: ->
      @get('streams').length < @maxStreams

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
        @collection.each @renderTweet

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
        @$el.attr 'class', "#{@className} #{@model.get 'category'}"
        @$el.html _.template Templates.tweet, @model.toJSON() 
        if $("##{@$el.attr 'id'}").length is 0
            $(@options.parentEl).prepend @el
        @$('.time-ago').timeago()

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

    initialize: =>
        @collection.bind 'add', @renderStream
        @collection.bind 'reset', @render
        @render()
    render: =>
        @collection.each @renderStream
    renderStream: (stream) =>
        streamView = new StreamView {model: stream}

class StreamView extends View

    tagName: "article"
    className: "stream"
    events:
        'click .name': 'editName'
        'submit .edit-name-form': 'saveName'
        'click .edit-name': 'editName'
        'click .save-name': 'saveName'
        'click .settings-btn': 'toggleSettings'
        'click .search-btn': 'addKeyword'
        'click .del': 'removeKeyword'

    initialize: =>
        @editingName = false
        @$el.attr 'id', "stream-#{@model.id or @model.cid}"
        @render()
        @model.on 'change:keywords', @renderKeywords
        @model.on 'change:name', @renderName

    render: =>
        @$el.html _.template Templates.stream, @model.toJSON()
        $('#streams').append @el
        @renderTweets()
        @renderKeywords()

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

    saveName: (evt)=>
        @model.save name: @$('.name input').val().trim()
        @model.trigger 'change:name'
        false
             
    renderTweets: =>
        tweets = new Tweets @model.get 'tweets'
        tweetsView = new TweetsView
            collection:tweets
            el:"#tweets-#{@model.id}"
            parentId:@model.id
        tweetsView.render()

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
        new StreamsView collection:@model.get 'streams'

    events:
        "click #new-stream-btn": "newStream"

    newStream: =>
      if @model.canMakeStream()
        @model.get('streams').create {name:'New Stream'}, {wait:true}
      else
        alert("Sorry, you can only create #{@model.maxStreams} streams")

$ ->
  authenticityToken = $("[name=csrf-token]").attr("content")
  window.app = app = new App()
  window.appView = appView = new AppView model:app
  console.log ":o::> Teach the Bird! <::o:"
