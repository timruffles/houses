require "bundler"
Bundler.setup
Bundler.require

TweetStream.configure do |config|
  config.consumer_key = 'Na4KBmmaQHYwO9CBsHfw'
  config.consumer_secret = 'XkYoM05QwiFaolj1LRZhLLYwF1kTP8scBAxhGFzOtJU'
  config.oauth_token = '144946031-ClXFGEFpI65K0Hox0BYIcyMWvv0LHc4TZ6TJPEYg'
  config.oauth_token_secret = '6nbggfL47aHQTFSHQbxPNUzPVInf63AC5nG2dQZCPo'
  config.auth_method = :oauth
end

redis = Redis.new
kwords = STDIN.read.split("\n").map(&:strip)
key = ARGV[0]
TweetStream::Client.new.track(kwords) do |status|
  puts status.text
  redis.sadd key, status.to_json
  redis.set "Last tweet received at #{Time.now.to_s}"
end

