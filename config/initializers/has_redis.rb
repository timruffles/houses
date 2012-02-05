HasRedis.redis_instance = if ["production","staging"].include? ENV["RAILS_ENV"]
  uri = URI.parse(ENV["REDISTOGO_URL"])
  Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)
else
  Redis.new
end

