require "test_helper"

class ErrorTest < Minitest::Test
  def test_error_callback_gets_run_for_unhandled_fetch_module_errors
    actions = []
    stub_request(:get, "http://test.com/one").to_return(body: "got one")
    mod = Class.new(Fetch::Module) do
      request do |req|
        req.url = "http://test.com/one"
        req.process do |body|
          this_wont_work!
        end
      end
    end
    klass = Class.new(MockFetcher(mod)) do
      error do |e|
        actions << "got #{e.message}"
      end
    end
    assert_raises NoMethodError do
      klass.new.fetch
    end
    assert_match /got undefined method `this_wont_work!'/, actions.first
  end

  [:modules, :load, :init, :before_fetch, :after_fetch, :progress].each do |callback|
    define_method "test_error_gets_run_when_#{callback}_callback_fails" do
      actions = []
      stub_request(:get, "http://test.com/one").to_return(body: "got one")
      mod = Class.new(Fetch::Module) do
        request do |req|
          req.url = "http://test.com/one"
        end
      end
      klass = Class.new(MockFetcher(mod)) do
        send(callback) do
          send "this_#{callback}_fails!"
        end

        error do |e|
          actions << "got #{e.message}"
        end
      end
      assert_raises NoMethodError do
        klass.new.fetch
      end
      assert_match /got undefined method `this_#{callback}_fails!'/, actions.first
    end
  end

  def test_error_callback_doesnt_run_for_handled_fetch_module_errors
    actions = []
    stub_request(:get, "http://test.com/one").to_return(body: "got one")
    mod = Class.new(Fetch::Module) do
      request do |req|
        req.url = "http://test.com/one"
        req.process do |body|
          this_wont_work!
        end
        req.error {}
      end
    end
    klass = Class.new(MockFetcher(mod)) do
      error do |e|
        actions << "got #{e.message}"
      end
    end
    klass.new.fetch
    assert_equal [], actions
  end
end