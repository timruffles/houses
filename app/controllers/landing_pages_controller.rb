class LandingPagesController < ApplicationController

  skip_authorization_check
  layout "landing_page"

  def index
    render :find
  end

  def research
    render :research
  end

  def sales
    render :sales
  end

  def marketing
    render :marketing
  end

end
