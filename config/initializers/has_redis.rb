HasRedis.redis_instance = if ["production","staging"].include? ENV["RAILS_ENV"]
  begin
    uri = URI.parse(ENV["REDISTOGO_URL"])
    Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)
  rescue StandardError => e
    STDERR.puts "Error: no redis to go url? Got any error in any case, so no redis for you!"
    STDERR.puts e
  end
else
  Redis.new
end
Resque.redis = HasRedis.redis
