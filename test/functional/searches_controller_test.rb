require 'test_helper'

class SearchesControllerTest < ActionController::TestCase
  setup do
    @user = Factory :user
  end
  test "creating and updating a search" do
    post :create, {:format => 'json', :search => { :keywords => "house hunting"}}, :user_id => @user.id
    assert_response :success
  end
end
