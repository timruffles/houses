module HasRedis
  @redis_instance = nil
  class << self
    attr_accessor :redis_instance
  end
  def redis
    HasRedis.redis_instance ||= Redis.new
  end
end
