url = require("url")
_ = require("underscore")
Iconv = require("iconv").Iconv

trailingWS = /^\s+|\s+$/
separators = /[,;_\-\.!?\(\)\{\}\[\]"&:*]/g
quotes = /\B["']\b|\b["']\B/
twitterCommands = /[#@]/g
possessives = /'s/g

module.exports = text =
  textToTrimmedWords: (phrase = "") ->
    phrase.split(" ").map((word) ->
            word.replace(trailingWS,"")
           ).filter (word) ->
            !/^\s*$/.test word
  normaliseWords: (phrase = "") ->
    phrase.toLowerCase()
          .replace(separators," ")
          .replace(quotes,"")
          .replace(possessives,"")
  twitterTextToKeywords: (phrase = "") ->
    text.textToTrimmedWords text.removeTwitterCommands text.normaliseWords phrase
  textToKeywords: (phrase) ->
    @textToTrimmedWords(phrase)
  textToPhrases: (string) ->
    string.split(",").map (phrase) ->
      text.textToTrimmedWords phrase
  removeTwitterCommands: (text) ->
    text.replace(twitterCommands," ")
  readUrl: (text) ->
    data = url.parse(text)
    [
      data.hostname
      data.pathname.replace("/"," ")
      data.query?.replace(/&=/," ")
    ].join " "
  tweetToKeywords: (tweet) ->
    _.flatten([
      tweet.text
      tweet.in_reply_to_screen_name
      tweet.user.name
      tweet.user.screen_name
      tweet.user.description
      tweet.entities.urls?.map((url) ->
        text.readUrl url.expanded_url || url.url
      ).join(" ")
      tweet.entities.media?.map((media) ->
        text.readUrl media.expanded_url || media.url
      ).join(" ")
    ].map((phrase) ->
      text.twitterTextToKeywords(phrase)
    ))
  transliterateToUtfBmp: (string) ->
    new Iconv("UTF-16","UTF-8//TRANSLIT").convert(new Iconv("UTF-8","UTF-16").convert(string)).toString("UTF-8")


