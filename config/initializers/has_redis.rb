module HasRedis
  @redis_instance = null
  class << self
    attr_accessor :redis_instance
  end
  def redis
    HasRedis.redis_instance ||= Redis.new
  end
end
class ActiveRecord::Base
end
