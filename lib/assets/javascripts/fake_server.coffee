server = sinon.fakeServer.create()
server.autoRespond = true
server.fakeHTTPMethods = true # allow _method like rails
server.autoRespondAfter = 800

json200 = (xhr,response) ->
  array = response.responseArray || [200, {"Content-Type": "application/json"}, JSON.stringify(response)]
  xhr.respond array...

apiUrl = (url) ->
  new RegExp("^#{url}.json".replace(/:id/g,"(\\d+)"))

postBody = (xhr) -> JSON.parse(xhr.requestBody)

responses =
  user: (id) ->
    console.log "fetching user..."
    name: "phil"
    id: "30cpodjc8"
  streams: ->
      console.log "fetching streams..."
      [{id:123, name:"foo", tweets:tweets, keywords:""},{id:456,name:"bar", tweets:tweets, keywords:""}]
  stream: (id) ->
    name: "estate agent house search"
    keywords: "house hunting, I need flat, give me flat, OH GOD FLATS"
    id: "123"
    tweets: tweets
  streamCreate: (xhr) ->
    console.log 'creating...'
    stream = postBody xhr
    stream.id = Math.random()*10
    stream.tweets = []
    stream
  streamUpdate: (xhr) ->
    console.log 'updating...'
    postBody xhr
  tweetUpdate: (xhr) ->
    postBody xhr

examples = []
setup = (method,url,handler,exampleData) ->
  server.respondWith method, url, handler
  examples.push arguments

setup "GET", apiUrl("/users/me"), (xhr,id) =>
  json200 xhr, responses.user(id)

setup "GET", apiUrl("/streams/mine"), (xhr) =>
    json200 xhr, responses.streams()

setup "GET", apiUrl("/streams/:id"), (xhr,id) =>
    json200 xhr, responses.stream(id)

setup "DELETE", apiUrl("/streams"), (xhr) =>
    json200 xhr, postBody xhr

setup "POST", apiUrl("/streams"), (xhr) =>
  json200 xhr, responses.streamCreate(xhr)
, {
    name: "Evil estate agent house search"
    keywords: "house hunting, I need flat, give me flat, OH GOD FLATS"
}
setup "PUT", apiUrl("/streams"), (xhr) =>
  json200 xhr, responses.streamUpdate(xhr)
,  {
    id: "areafprogksrigjosijfoisjr"
    keywords: "new list of keywords"
}

setup "PUT", apiUrl("/tweets/:id"), (xhr) =>
  json200 xhr, responses.tweetUpdate(xhr)
, {
  id: "141522834898960384"
  done: true
  state: "relevent"
}

window.push_tweet = 
    "created_at": "Tue Nov 29 14:24:07 +0000 2011"
    "id": "141522834898960384"
    "text": "#MomentsICanNeverForget gathering Hunt's at my house, karaoke, cupcakes and everything nice :D"
    "user": 
        "screen_name": 'Jung'
        "name": "junhyung's joker \342\235\244"
        "profile_background_tile": true
        "profile_image_url": "http://a0.twimg.com/profile_images/1612230687/likeeyyy_normal.jpg"
