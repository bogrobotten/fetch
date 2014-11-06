require "test_helper"

class ErrorTest < Minitest::Test
  def test_unhandled_process_error
    stub_request(:get, "http://test.com/one").to_return(body: "ok")
    actions = []
    mod = Class.new(Fetch::Module) do
      request do |req|
        req.url = "http://test.com/one"
        req.process do |body|
          this_wont_work
        end
      end
    end
    assert_raises NameError do
      MockFetcher(mod).new.fetch
    end
  end

  def test_process_error_handled_in_request
    stub_request(:get, "http://test.com/one").to_return(body: "ok")
    actions = []
    mod = Class.new(Fetch::Module) do
      request do |req|
        req.url = "http://test.com/one"
        req.error do |e|
          actions << "handled #{e.class.name}"
        end
        req.process do |body|
          this_wont_work
        end
      end
    end
    MockFetcher(mod).new.fetch
    assert_equal ["handled NameError"], actions
  end

  def test_process_error_scope_handled_in_request
    stub_request(:get, "http://test.com/one").to_return(body: "ok")
    actions = []
    mod = Class.new(Fetch::Module) do
      request do |req|
        req.url = "http://test.com/one"
        req.error do |e|
          actions << "handled #{e.class.name} (#{some_instance_method})"
        end
        req.process do |body|
          this_wont_work
        end
      end

      def some_instance_method
        "it worked"
      end
    end
    MockFetcher(mod).new.fetch
    assert_equal ["handled NameError (it worked)"], actions
  end

  def test_process_error_handled_in_module
    stub_request(:get, "http://test.com/one").to_return(body: "ok")
    actions = []
    mod = Class.new(Fetch::Module) do
      request do |req|
        req.url = "http://test.com/one"
        req.process do |body|
          this_wont_work
        end
      end
      error do |e|
        actions << "handled #{e.class.name}"
      end
    end
    MockFetcher(mod).new.fetch
    assert_equal ["handled NameError"], actions
  end

  def test_process_error_scope_handled_in_module
    stub_request(:get, "http://test.com/one").to_return(body: "ok")
    actions = []
    mod = Class.new(Fetch::Module) do
      request do |req|
        req.url = "http://test.com/one"
        req.process do |body|
          this_wont_work
        end
      end
      error do |e|
        actions << "handled #{e.class.name} (#{some_instance_method})"
      end
      def some_instance_method
        "it worked"
      end
    end
    MockFetcher(mod).new.fetch
    assert_equal ["handled NameError (it worked)"], actions
  end
end