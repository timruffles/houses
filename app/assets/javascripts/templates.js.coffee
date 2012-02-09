window.Templates =
  stream: """
    <header class="stream-header">
      <h1 class="name"><%= name %></h1> 
      <span class="settings-btn iconic"> </span>
      <section class="settings" style="display:none">
          <input class="search-input" type="text"/>
          <span class="search-btn">Search</span>
          <div class="keywords"></div>
      </section>
    </header> 
    <section id="tweets-<%=id%>" class="tweets">
      <h2>No tweets yet, add some keywords...</h2>
    </section>
  """
  tweet: """
    <img class="profile_image" src="<%=user.profileImageUrl%>" />
    <p>
       <span class="username"><%=user.name%></span>
        <span class="screenname"><%=('@'+user.screenName).parseUsername()%> 
    </p>
    <span class="text"><%= text.parseURL().parseUsername().parseHashtag() %></span>
    <div class="time-ago" title="<%=createdAt%>"></div>
    <div class="actions" style="display:none"><span class="yes">Yes</span> | <span
    class="no">no</span></div>
  """
