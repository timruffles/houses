String.prototype.parseURL = function() {
	return this.replace(/[A-Za-z]+:\/\/[A-Za-z0-9-_]+\.[A-Za-z0-9-_:%&~\?\/.=]+/g, function(url) {
	  var link="<a target='_blank' href='"+url+"'>"+url+"</a>"
    return link;
	});
};
String.prototype.parseUser = function() {
	return this.replace(/[@]+[A-Za-z0-9-_]+/g, function(u) {
		var username = u.replace("@","")
		return u.link("https://twitter.com/intent/user?screen_name="+username);
	});
};
String.prototype.parseHashtag = function() {
	return this.replace(/[#]+[A-Za-z0-9-_]+/g, function(t) {
		var tag = t.replace("#","%23")
    var href="http://search.twitter.com/search?q="+tag
    var link="<a target='_blank' href='"+href+"'>"+t+"</a>"
		return link;
	});
};
