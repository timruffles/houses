require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  setup do
    @user = Factory :user
  end
  test "can see myself" do
    get :me, {:format => :json}, {:user_id => @user}
    assert_response :success
  end
end
