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

    url: "/streams"
    initialize: =>
        
        @tweetsCollection = new Tweets @get 'tweets'
        
        # Testing code (to be removed) 
        
        if @id is 123 then window.setInterval( =>
                window.push_tweet.id = "#{parseInt(Math.random()*100)}" 
                @tweetsCollection.add camelize window.push_tweet
            , 
                5000)
        ###
        PUBNUB?.subscribe
            channel: "search:#{@id}:tweets:add"
            callback: (message) =>
                message = camelize message
                @tweetsCollection.add message.tweet
        ###
        
        @keywordCollection = new (Collection.extend
            model: Model.extend(idAttribute: "word")
        )
        @keywordCollection.on "add", @syncKeywords
        @keywordCollection.on "remove", @syncKeywords
        @keywordCollection.reset (@get('keywords') || "")
                .split(",")
                .map((w) -> w.trim())
                .filter((w) -> w != "")
                .map((w) -> word: w)
    
    syncKeywords: => 
        @save keywords: @keywordCollection.pluck("word").join(", ") 

    keywords: =>
        @keywordCollection.pluck "word"

    addKeyword: (word) =>
        if word.length is 0 or typeof word not in ["string","object"]
            return false
        words = if typeof word is 'object' then word else [word]
        keywords = []
        _.each words, (word) =>
            (keywords.push word:word) if not @keywordCollection.get word
        if not keywords.length 
            return false
        @keywordCollection.add keywords  
        true

    removeKeyword: (word) =>
        @keywordCollection.remove(word)

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
        @render()

    render: =>
        if @collection.models.length > 0 then @$el.html ""
        @collection.each @renderTweet

    renderTweet: (tweet) =>
        new TweetView
            model: tweet
            parentId:@options.parentId
            parentEl:@el

class TweetView extends View

    tagName: "article"
    className: "tweet"

    events:
        "click .yes": "markAsRelevant"
        "click .no": "markAsIrrelevant"

    initialize: =>
        @$el.attr 'id', "tweet-#{@options.parentId}-#{@model.id}"
        @model.on 'change:id', @render
        @model.on 'change:category', @renderCategory
        @$el.mouseenter(@showActions).mouseleave(@hideActions)
        @render()
  
    render: =>
        @renderCategory() if @model.get 'category'              
        @$el.html _.template Templates.tweet, @model.toJSON() 
        if $("##{@$el.attr 'id'}").length is 0 
            $(@options.parentEl).prepend @el
            h = @$el.height() 
            @$el.css('top',"-#{h}px")
            @$el.animate {top:"0"} 
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

    initialize: =>
        @collection.bind 'add', @renderStream
        @collection.bind 'reset', @render
        @render()

    render: =>
        @collection.each @renderStream

    renderStream: (stream) =>
        streamView = new StreamView {model: stream}

class StreamView extends View

    tagName  : "article"
    className: "stream"

    events:
        'click  .stream.closed .stream-header': 'toggleSettings'
        'click  .stream.open .toggle-settings': 'toggleSettings'
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
        $('#streams').append @el
        @renderTitle()
        @renderKeywords()
        @renderTweets()

    renderTitle: =>
        keywords = @model.keywords()  
        if keywords.length is 0
            title = "Add keywords here..."
            @$el.addClass "no-keywords"
        else
            @$el.removeClass "no-keywords"
            title = keywords.join(', ')
            if title.legnth > 12 then title = title.slice(0,11) + '...'
        @$('.stream-title').html title

    renderKeywords: =>
        $keywords = @$('.keywords')
        $keywords.html ""
        _.each @model.keywords(), (word) =>
            $keywords.append  _.template Templates.keywords, {word:word}
        @adjustSettingsSize()
       
    editKeywords: =>
        @$('.stream-title').html _.template Templates.editKeywords
        @$('.add-keyword-form input').focus()

    addKeyword: (evt) =>
        $input = @$('.add-keyword-form input')
        if @model.addKeyword $input.val().trim().split(',')
            $input.val('')
        false

    removeKeyword: (evt) ->
        word = $(evt.currentTarget).parent().find('.word').html().trim()
        console.log word
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
            @$('.tweets').animate top: 51
            @$('.stream-header').animate height: '44px'
        else 
            h = 60 + parseInt @$('.settings').css('height').replace('px', '')
            @$('.tweets').animate top: 10+h
            @$('.stream-header').animate height: "#{h}px"
    
    removeStream: =>
        @model.destroy() 

    renderTweets: =>
        new TweetsView
            collection: @model.tweetsCollection
            el:"#tweets-#{@model.id}"
            parentId:@model.id

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
        twttr.anywhere (T) -> 
            T.hovercards()
            T(".profile_image").hovercards username: (node) -> node.alt
        

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
