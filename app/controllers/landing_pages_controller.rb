class LandingPagesController < ApplicationController

  skip_authorization_check
  layout "landing_page"

  def index
    render :find
  end

end
