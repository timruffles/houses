require 'test_helper'

class SearchTest < ActiveSupport::TestCase
  def expect_publish
    mock_redis = mock
    mock_redis.expects(:publish).once
    Search.stubs(:redis => mock_redis)
  end
  test "publishes updates on create" do
    expect_publish
    Search.create
  end
  test "publishes updates on create" do
    search = Search.create
    expect_publish
    search.update_attributes :keywords => "new keywords"
  end
end
