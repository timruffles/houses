class User < ActiveRecord::Base
  has_many :searches
  include PublishesCallbacks
  def self.create_with_omniauth(auth)
    create! do |user|
      user.provider = auth["provider"]
      user.uid = auth["uid"]
      user.name = auth["info"]["name"]
    end
  end
  after_create :publish_token
  after_update :publish_token
  def publish_token
    publish_callback "after_update", {
      oauth_token: oauth_token,
      oauth_secret: oauth_secret
    }
  end
  def as_json_clientside options = {}
    as_json options.merge(:except => ["oauth_token","oauth_secret"])
  end
end
