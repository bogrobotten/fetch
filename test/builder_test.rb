require "test_helper"

class BuilderTest < Minitest::Test
  def test_basic_builder
    builder = Class.new do
      include Fetch::Builder
      request do |req|
        req.url = "http://test.com/one"
      end
      request do |req|
        req.url = "http://test.com/two"
      end
    end

    urls = builder.new.requests.map(&:url)
    assert_equal ["http://test.com/one", "http://test.com/two"], urls
  end

  def test_empty_builder
    builder = Class.new do
      include Fetch::Builder
    end

    urls = builder.new.requests.map(&:url)
    assert_equal [], urls
  end
end