require "test_helper"

class FetchTest < Minitest::Test
  def test_basic_fetch
    stub_request(:get, "http://test.com/one").to_return(body: "got one")
    actions = []
    mod = Class.new(Fetch::Module) do
      request do |req|
        req.url = "http://test.com/one"
        req.process do |body|
          actions << "body: #{body}"
        end
      end
    end
    MockFetcher(mod).new.fetch
    assert_equal ["body: got one"], actions
  end

  def test_positive_fetch_if_filter
    stub_request(:get, "http://test.com/one").to_return(body: "got one")
    actions = []
    mod = Class.new(Fetch::Module) do
      fetch_if { should_i_fetch? }

      request do |req|
        req.url = "http://test.com/one"
        req.process do |body|
          actions << "body: #{body}"
        end
      end

      def should_i_fetch?
        true
      end
    end
    MockFetcher(mod).new.fetch
    assert_equal ["body: got one"], actions
  end

  def test_negative_fetch_if_filter
    stub_request(:get, "http://test.com/one").to_return(body: "got one")
    actions = []
    mod = Class.new(Fetch::Module) do
      fetch_if { should_i_fetch? }

      request do |req|
        req.url = "http://test.com/one"
        req.process do |body|
          actions << "body: #{body}"
        end
      end

      def should_i_fetch?
        false
      end
    end
    MockFetcher(mod).new.fetch
    assert_equal [], actions
  end

  def test_nil_fetch_if_filter
    stub_request(:get, "http://test.com/one").to_return(body: "got one")
    actions = []
    mod = Class.new(Fetch::Module) do
      fetch_if { should_i_fetch? }

      request do |req|
        req.url = "http://test.com/one"
        req.process do |body|
          actions << "body: #{body}"
        end
      end

      def should_i_fetch?
        nil
      end
    end
    MockFetcher(mod).new.fetch
    assert_equal [], actions
  end

  def test_multiple_requests
    words = %w{one two three}
    words.each { |w| stub_request(:get, "http://test.com/#{w}").to_return(body: "got #{w}") }
    actions = []

    mod = Class.new(Fetch::Module) do
      words.each do |w|
        request do |req|
          req.url = "http://test.com/#{w}"
          req.process do |body|
            actions << "body: #{body}"
          end
        end
      end
    end
    MockFetcher(mod).new.fetch
    assert_equal ["body: got one", "body: got two", "body: got three"], actions
  end

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
end
