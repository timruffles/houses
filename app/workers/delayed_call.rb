class DelayedCall
  @queue = :low
  def self.perform klass, method, id
    const_get(klass).send method, id
  end
end
