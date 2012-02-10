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
