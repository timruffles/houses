twIntent = "https://twitter.com/intent"
window.Templates =
  stream: """
    <header class="stream-header">
        <h1 class="stream-title"></h1>
        <span class="toggle-settings iconic"></span>
        <section class="settings">
            <section class="keywords"></section>
            <div>
            <span class="remove-stream iconic"> Delete this stream</span>            
            </div>
      </section>
    </header> 
    <section class="tweets">
        <span class="help">
        Add some kewords to start getting tweets!
        </span>
    </section>
  """
  keywords:"""
    <span class='keyword'>
        <span class='word'><%=word%></span>
        <span class='remove-keyword iconic'></span>
    </span>
  """
  editKeywords:"""
    <form class='add-keyword-form'><input type='text'/></form>
    <span class='add-keyword iconic'></span>
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


