class Tweet extends Backbone.Model
   
    url: "/tweets"

class Stream extends Backbone.Model

    url: "/streams"

    initialize: =>
        @set name: "New Search", keywords:null, tweets: {} 

class TweetView extends Backbone.View
   
    className: 'tweet'
    tagName: 'li'

    initialize: => 
        @model.bind 'change', @render

    events:
        "click .yes": "markAsRelevant"
        "click .no": "markAsIrelevant"

    render: => 
        state = @model.get 'state'
        yesBtn = "<a class='button small yes'>Yes</a>"
        noBtn =  "<a class='button small no' >No</a>" 
        text = (@model.get 'text').parseURL().parseUsername().parseHashtag()
        html = "#{yesBtn} #{noBtn} <span class='text'>#{text}</span>"
        $el = $ @el
        id = @className + "-" + @model.id 
        $el.attr class: @className + " " + @model.get 'state'
        if $("##{id}").length is 0 
            $el.attr id: id  
            $('#tweets').append $el.html html
        else
            $el.html html

    markAsRelevant: =>
        @model.save state: "relevant"
    markAsIrelevant: =>
        @model.save state: "irelevant"

class StreamView extends Backbone.View 

    el: "#stream"

    events:    
        "click #name-label": "editName"
        "click #name-container a.button": "saveName"
        "click #search": "search"
    
    initialize: =>
        if not @model then @model = new Stream()
        @model.bind 'change', @render
    
    render: => 
        @renderName()
        if @model.id then @renderLink()
        if @model.get 'keywords' then @renderKeywords()
        @renderTweets()

    renderName: =>
        tpl = "<span class='name' id='name-label'>#{@model.get 'name'}</span>"
        $('#name-container').html tpl

    renderLink: =>
        link = "http://is.gd/R7dwI0e"
        html = "Bookmark this stream: <a href='#{link}'>#{link}</a>"
        $('#link-container').html html

    renderKeywords: =>
        tpl = (keyword) -> "<span class='keyword'>#{keyword}</span>"
        keywords = (@model.get 'keywords').split ','
        $keywords = $('#keywords')
        $keywords.html ""
        $keywords.append tpl keyword for keyword in keywords

    renderTweets: =>
        $('#tweets').html ""
        tweets = @model.get 'tweets' 
        ( 
            (new TweetView model: (new Tweet tweet)).render()
        ) for tweet in tweets
  
    editName: =>
        name = @model.get 'name'
        tpl = "<input type='text' value='#{name}'/> <a class='button'>save</a>"
        $('#name-container').html tpl

    saveName: =>
        name = $('#name-container input').first().val()
        tpl = "<span class='name' id='name-label'>#{name}</span>"
        $('#name-container').html tpl
        @model.save {name: name}

    search: =>
        keyword = $('#search-input').val().trim()
        keywords = @model.get "keywords"
        if keywords then keywords = keywords.split()
        else keywords = []
        return if keyword is "" or keyword in keywords
        keywords.push keyword
        @model.save {keywords: keywords.toString()}      
#
# Router
#
class AppRouter extends Backbone.Router
   
    routes:
        ""           : "new"
        "streams/:id": "stream"
      
    new: => 
        @streamView = new StreamView()
        @streamView.render()

    stream: (id) =>
        @stream = new Stream { id: id }
        @streamView = new StreamView { model: @stream }
        @stream.fetch url: "#{@stream.url}/#{id}"
  
# Start the app
#
$ =>
    console.log "Welcome to the app!" 
    window.app = new AppRouter()
    Backbone.history.start()
