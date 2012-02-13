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
    <section id="tweets-<%=id%>" class="tweets">
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
