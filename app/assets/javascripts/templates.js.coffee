window.Templates =
  stream: """
    <header class="stream-header"> 
      <h1 class="name"><%= name %></span></h1>
      <span class="iconic edit-name"></span>
      <span class="iconic save-name"></span>
      <span class="settings-btn iconic"> </span>
      <section class="settings" style="display:none">
          <input class="search-input" type="text"/>
          <span class="search-btn">Search</span>
          <div class="keywords"></div>
          <div class="delete-zone">
          <span class="delete-stream iconic"></span> Delete this stream?</div>
      </section>
    </header> 
    <section id="tweets-<%=id%>" class="tweets">
      <h2>No tweets yet, add some keywords...</h2>
    </section>
  """
  tweet: """
    <img class="profile_image" src="<%=user.profileImageUrl%>" alt="<%='@'+user.screenName%>"/>
    <p>
       <span class="username"><%=user.name%></span>
       <span class="screenname"><%='@'+user.screenName%></span>
    </p>
    <span class="text"><%= text.parseURL().parseHashtag() %></span>
    <div class="time-ago" title="<%=createdAt%>"></div>
    <div class="actions" style="display:none"><span class="iconic yes"> Yes</span> | <span
    class="iconic no"> No</span></div>
  """
  addStream: addStream = """
    <form class="create-stream">
      <input type="text" class="keywords" />
      <button class="btn large">Create Stream</button>
    </form>
  """
  tutorials:
    0: """
      <p class="tutorial">
        Enter words you're interested in and click 'create stream'.
      </p>
      #{addStream}
    """
    1: """
      <p class="tutorial">
        Teach the bird which tweets are interesting you by hovering over them and clicking "Yes" or "No".
      </p>
      #{addStream}
    """
    2: """
      <p class"tutorial">
        Thanks for using Teach the Bird! If you find us useful, it'd help us so much if you told your followers!
      </p>
      <p class="tutorial">
        Made with love by @pcole and @timruffles :)
      </a>
    """
    3: addStream


