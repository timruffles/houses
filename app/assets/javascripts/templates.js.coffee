twIntent = "https://twitter.com/intent"
window.Templates =
  stream: """
    <header class="stream-header"> 
      <h1 class="name"><%= name %></span></h1>
      <span class="iconic edit-name"></span>
      <span class="iconic save-name"></span>
      <span class="settings-btn iconic"> </span>
      <section class="settings" style="display:none">
          <input class="search-input" type="text" placeholder="Keywords you're interested in" />
          <span class="search-btn">Search</span>
          <div class="keywords"></div>
          <div class="delete-zone">
          <span class="delete-stream iconic"></span> Delete this stream?</div>
      </section>
    </header> 
    <section class="tweets">
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
      <input type="text" class="keywords" placeholder="Keywords you're interested in" />
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
      <button class="next large btn">Got it -></button>
    """
    2: """
      <p class="tutorial">
        Thanks for using Teach the Bird! If you find us useful, it'd help us so much if you told your followers!
      </p>
      <p>
        <a class="large btn blue btn-info next" target="_blank" href="#{twIntent}/tweet?text=#{encodeURIComponent '@teachthebird'}">Tweet about us</a>
        <button class="large btn next">Nope</button>
      <p>
        Made with love by <a href="#{twIntent}/user?screen_name=philip_cole">@pcole</a> and <a href="#{twIntent}/user?screen_name=timruffles">@timruffles</a> :)
      </a>
    """
    3: addStream


