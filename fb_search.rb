require "bundler"
Bundler.setup
Bundler.require
require "date"

redis = Redis.new

term = ARGV[0]

last_search = redis.hget("last_searched", term)
limit = last_search ? Date.parse(last_search) : Date.parse(Time.now.to_s) - 30

require "cgi"
require "open-uri"

def read term, limit, redis
  puts "searching for #{term}, since #{limit}"
  result = nil
  url = "https://graph.facebook.com/search?q=#{CGI.escape(term)}&type=post"
  date = nil
  until result && (date > limit || result["data"].length == 0)
    result = JSON.parse open(url).read
    puts "read #{result["data"].length} statuses"
    result["data"].each do |s| yield s end
    url = result["paging"]["previous"]
    date = Date.parse(Time.at(result["paging"]["previous"][/since=(\d+)/,1].to_i).to_s)
    redis.hset "last_searched", term, Date.parse(result["data"].last["created_time"])
  end
end

read term, last_search, redis do |result|
  likes = (result["likes"] || {})["count"]
  store = {:id => result["id"], :message => result["message"], :likes => likes || 0}
  redis.sadd "facebook_#{term.gsub(/[^a-z]/i,"")}", store.to_json 
  puts "Stored #{store}"
end
