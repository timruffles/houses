Twitter = require("ntwitter")
class UserLocation
  constructor: (@user,@pg) ->
    @twitter = new Twitter
      consumer_key: env.TW_KEY
      consumer_secret: env.TW_SECRET
      access_token_key: @user.oauth_token
      access_token_secret: @user.oauth_secret
  identify: ->
    @twitter.showUser @user.id, (err,user) ->
      if user.geo_enabled
        # use geo data from here, or create a probability
        # based on ppl they follow:
  identified: (location) ->

