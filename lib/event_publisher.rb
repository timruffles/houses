class EventPublisher
  def event event, keys
    redis.publish "modelUpdates", {
      :type => self.class.to_s,
      :event => event,
      :id => self.id,
    }.merge(keys).to_json
  end
end
