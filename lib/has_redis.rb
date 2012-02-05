require "redis"
module HasRedis
  class << self
    attr_accessor :redis_instance
  end
  def redis
    ::HasRedis.redis_instance
  end
end

