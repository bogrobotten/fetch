require "test_helper"

class ProgressTest < Minitest::Test
  def test_progress_with_single_module
    stub_request(:get, "http://test.com/one").to_return(body: "got one")

    mod = Class.new(Fetch::Module) do
      3.times do
        request do |req|
          req.url = "http://test.com/one"
        end
      end
    end

    updates = []

    klass = Class.new(MockFetcher(mod)) do
      progress do |percent|
        updates << percent
      end
    end

    klass.new.fetch
    assert_equal [0, 33, 66, 100], updates
  end

  def test_progress_with_multiple_modules
    stub_request(:get, "http://test.com/one").to_return(body: "got one")

    mods = 3.times.map do
      Class.new(Fetch::Module) do
        2.times do
          request do |req|
            req.url = "http://test.com/one"
          end
        end
      end
    end

    updates = []

    klass = Class.new(MockFetcher(mods)) do
      progress do |percent|
        updates << percent
      end
    end

    klass.new.fetch
    assert_equal [0, 16, 33, 50, 66, 83, 100], updates
  end

  def test_progress_with_http_failure
    stub_request(:get, "http://test.com/one").to_return(body: "something went wrong", status: 500)
    updates = []
    mods = 3.times.map do
      Class.new(Fetch::Module) do
        request do |req|
          req.url = "http://test.com/one"
        end
      end
    end
    klass = Class.new(MockFetcher(mods)) do
      progress do |percent|
        updates << percent
      end
    end

    klass.new.fetch
    assert_equal [0, 33, 66, 100], updates
  end

  def test_progress_with_handled_process_error
    stub_request(:get, "http://test.com/one").to_return(body: "ok")
    updates = []
    mods = 3.times.map do
      Class.new(Fetch::Module) do
        request do |req|
          req.url = "http://test.com/one"
          req.process do |body|
            wont_work
          end
          req.error { }
        end
      end
    end
    klass = Class.new(MockFetcher(mods)) do
      progress do |percent|
        updates << percent
      end
    end

    klass.new.fetch
    assert_equal [0, 33, 66, 100], updates
  end
end