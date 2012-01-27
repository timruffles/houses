class Search < ActiveRecord::Base
  before_save do
    return unless keywords.changed?
    redis.publish "modelUpdates", {
      :type => "Search",
      :id => self.id,
      :changed => {
        :keywords => self.keywords
      }
    }.to_json
  end
end
