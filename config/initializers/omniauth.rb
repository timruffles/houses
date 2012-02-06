Rails.application.config.middleware.use OmniAuth::Builder do
  provider :twitter, ENV['TW_KEY'], ENV['TW_SECRET']
end
