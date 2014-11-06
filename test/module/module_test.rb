require "test_helper"

class ModuleTest < Minitest::Test
  def test_fetch_using_get
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

  def test_fetch_using_post
    stub_request(:post, "http://test.com/create").to_return(->(req) { { body: "you posted: #{req.body}" } })
    actions = []
    mod = Class.new(Fetch::Module) do
      request do |req|
        req.method = :post
        req.url = "http://test.com/create"
        req.body = { one: 1, two: 2 }
        req.process do |body|
          actions << "body: #{body}"
        end
      end
    end
    MockFetcher(mod).new.fetch
    assert_equal ["body: you posted: one=1&two=2"], actions
  end

  def test_empty_url
    stub_request(:get, "http://test.com/one").to_return(body: "got one")

    actions = []
    mod = Class.new(Fetch::Module) do
      2.times do
        request do |req|
          req.url = "http://test.com/one"
          req.process do |body|
            actions << "process: #{body}"
          end
        end
      end
      2.times do
        request do |req|
          req.process do |body|
            actions << "process: #{body}"
          end
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
    assert_equal ["process: got one", "process: got one"], actions
    assert_equal [0, 50, 100], updates
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
end