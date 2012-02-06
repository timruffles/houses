require 'test_helper'

class SearchTest < ActiveSupport::TestCase
  def expect_publish
    @search.expects(:publish_callback).once
  end
  test "publishes updates on create" do
    @search = Factory.build :search
    expect_publish
    @search.save
  end
  test "publishes updates on update" do
    @search = Factory :search
    expect_publish
    @search.keywords = "new keywords"
    @search.save
  end
end
