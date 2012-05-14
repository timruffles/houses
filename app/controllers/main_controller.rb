class MainController < ApplicationController
  skip_authorization_check
  layout :choose_layout
  def choose_layout
    current_user.nil? ? "landing_page" : "application"
  end
  def index
  end
end
