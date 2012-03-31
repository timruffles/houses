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
              <button class="done large btn"><span class="iconic"></span> Done</button>
              <a class="btn export">Export</a>
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
    <form class='add-keyword-form'><input placeholder="Keywords you're interested in" type='text'/></form>
    <span class='add-keyword iconic'></span>
  """
  tweet: """
    <a href="https://twitter.com/intent/user?screen_name=<%= user.screenName %>">
      <img class="profile_image" src="<%=user.profileImageUrl%>" alt="<%='@'+user.screenName%>"/>
    </a>
    <p class="user-info">
       <span class="username"><%=user.name%></span>
       <a href="https://twitter.com/intent/user?screen_name=<%= user.screenName %>" class="screenname"><%='@'+user.screenName%></a>
    </p>
    <span class="text"><%= text.parseURL().parseUser().parseHashtag() %></span>
    <div class="time-ago" title="<%=createdAt%>"></div>
    <div class="actions hidden">
        <span class="iconic yes"> Yes</span> 
        <span class="iconic no"> No</span> 
        <span class="intents"><a href="https://twitter.com/intent/tweet?in_reply_to=<%=id %>">Reply</a>
        <a href="https://twitter.com/intent/retweet?tweet_id=<%=id %>">Retweet</a>
        <a href="https://twitter.com/intent/favorite?tweet_id=<%=id %>">Favorite</a></span>
    </div>
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
        Teach the bird which tweets are interesting by hovering over them and clicking "Yes" or "No".
      </p>
      <div class="yes-no-tutorial">
      </div>
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


