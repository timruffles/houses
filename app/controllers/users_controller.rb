class UsersController < ApplicationController
  load_resource
  authorize_resource
  respond_to :json
  def me
    respond_with current_user
  end
end
