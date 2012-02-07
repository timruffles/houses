streamTemplate = """
  <header class="stream-header">
    <h1 class="name"><%= name %></h1> 
    <span class="settings-btn">Settings</span>
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

