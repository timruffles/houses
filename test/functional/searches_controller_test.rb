require 'test_helper'

class SearchesControllerTest < ActionController::TestCase
  setup do
    @user = Factory :user
  end
  test "creating a search" do
    post :create, {:format => 'json', :search => { :keywords => "house hunting"}}, :user_id => @user.id
    assert_response :success
  end
  test "updating a search" do
    search = Factory :search, :keywords => "house party", :user => @user
    post :update, {:format => 'json', :search => { :keywords => "house hunting"}, :id => search.id}, :user_id => @user.id
    assert_response :success
    search.reload
    assert_equal search.keywords, "house hunting"
  end
  test "removing a search" do
    search = Factory :search, :keywords => "house party", :user => @user
    post :destroy, {:format => 'json', :id => search.id}, :user_id => @user.id
    assert_response :success
  end
  test "seeing my searches" do
    2.times { Factory :search, :user => @user }
    get :mine, {:format => 'json'}, :user_id => @user.id
    assert_response :success
    json = JSON.parse @response.body
    assert_equal json.length, 2
    assert_equal json[0]['user_id'], @user.id
  end
end
