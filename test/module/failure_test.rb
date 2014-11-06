require "test_helper"

class FailureTest < Minitest::Test
  def test_unhandled_http_failure
    stub_request(:get, "http://test.com/one").to_return(body: "something went wrong", status: 500)
    actions = []
    mod = Class.new(Fetch::Module) do
      request do |req|
        req.url = "http://test.com/one"
        req.process do |body|
          actions << "body: #{body}"
        end
      end
    end
    assert_equal [], actions
  end

  def test_http_failure_handled_in_request
    stub_request(:get, "http://test.com/one").to_return(body: "something went wrong", status: 500)
    actions = []
    mod = Class.new(Fetch::Module) do
      request do |req|
        req.url = "http://test.com/one"
        req.failure do |code, url|
          actions << "handled error #{code} from #{url}"
        end
        req.process do |body|
          actions << "body: #{body}"
        end
      end
    end
    MockFetcher(mod).new.fetch
    assert_equal ["handled error 500 from http://test.com/one"], actions
  end

  def test_http_failure_scope_handled_in_request
    stub_request(:get, "http://test.com/one").to_return(body: "something went wrong", status: 500)
    actions = []
    mod = Class.new(Fetch::Module) do
      request do |req|
        req.url = "http://test.com/one"
        req.failure do |code, url|
          actions << "handled error #{code} from #{url} (#{some_instance_method})"
        end
        req.process do |body|
          actions << "body: #{body}"
        end
      end

      def some_instance_method
        "it worked"
      end
    end
    MockFetcher(mod).new.fetch
    assert_equal ["handled error 500 from http://test.com/one (it worked)"], actions
  end

  def test_http_failure_handled_in_module
    stub_request(:get, "http://test.com/one").to_return(body: "something went wrong", status: 500)
    actions = []
    mod = Class.new(Fetch::Module) do
      request do |req|
        req.url = "http://test.com/one"
        req.process do |body|
          actions << "body: #{body}"
        end
      end
      failure do |code, url|
        actions << "handled error #{code} from #{url}"
      end
    end
    MockFetcher(mod).new.fetch
    assert_equal ["handled error 500 from http://test.com/one"], actions
  end

  def test_http_failure_scope_handled_in_module
    stub_request(:get, "http://test.com/one").to_return(body: "something went wrong", status: 500)
    actions = []
    mod = Class.new(Fetch::Module) do
      request do |req|
        req.url = "http://test.com/one"
        req.process do |body|
          actions << "body: #{body}"
        end
      end
      failure do |code, url|
        actions << "handled error #{code} from #{url} (#{some_instance_method})"
      end
      def some_instance_method
        "it worked"
      end
    end
    MockFetcher(mod).new.fetch
    assert_equal ["handled error 500 from http://test.com/one (it worked)"], actions
  end
end