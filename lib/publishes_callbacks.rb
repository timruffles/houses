module PublishesCallbacks
  include HasRedis
  def publish_callback callback, data = {}
    redis.rpush "model_updates", data.merge({
      :type => self.class.to_s,
      :callback => callback.to_s,
      :id => self.id
    }).to_json
    redis.publish "enqueued:model_updates", true
  end
end
