module PublishesCallbacks
  include HasRedis
  def publish_callback callback, data = {}
    redis.publish "modelUpdates", data.merge({
      :type => self.class.to_s,
      :callback => callback.to_s,
      :id => self.id
    }).to_json
  end
end
