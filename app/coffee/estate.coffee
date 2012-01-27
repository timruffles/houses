server = sinon.fakeServer.create()
server.autoRespond = true
server.fakeHTTPMethods = true # allow _method like rails
server.autoRespondAfter = 800

json200 = (xhr,response) ->
  array = response.responseArray || [200, {"Content-Type": "application/json"}, JSON.stringify(response)]
  xhr.respond array...

apiUrl = (url) ->
  new RegExp("^#{url}".replace(/:id/g,"(\\d+)"))

postBody = (xhr) -> JSON.parse(xhr.requestBody)

responses =
  stream: (id) ->
    name: "Evil estate agent house search"
    keywords: "house hunting, I need flat, give me flat, OH GOD FLATS"
    id: "123"
    tweets: tweets
  streamCreate: (xhr) ->
    console.log 'creating....'
    stream = postBody xhr
    stream.id = "apoapiw"
    stream.tweets = tweets
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

setup "GET", apiUrl("/streams/(\\w+)"), (xhr,id) =>
  json200 xhr, responses.stream(id)

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

setup "PUT", apiUrl("/tweets"), (xhr) =>
  json200 xhr, responses.tweetUpdate(xhr)
, {
  id: "141522834898960384"
  done: true
  state: "relevent"
}

examples.forEach ([method,url,handler,exampleData]) ->
  url = url.toString().replace("/^","").replace("(\\w+)","areafprogksrigjosijfoisjr").replace(/\/$/,"")
  $.ajax 
    url: url
    data: if exampleData then JSON.stringify(exampleData) else null
    dataType: "json"
    contentType: 'application/json'
    type: method
    success: (resp) ->
      console.log "#{method} to #{url}, response:", resp
