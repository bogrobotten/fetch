require "test_helper"

class BuilderTest < Minitest::Test
  def test_basic_runner
    stub_request(:get, "http://test.com/one").to_return(body: "got one")
    actions = []
    builder = Class.new do
      include Fetch::Builder
      request do |req|
        req.url = "http://test.com/one"
        req.process do |body|
          actions << "process: #{body}"
        end
      end
    end
    runner = Fetch::Runner.new(builder.new)
    runner.run
    assert_equal ["process: got one"], actions
  end

  def test_runner_with_multiple_requests
    words = %w{one two three}
    words.each { |w| stub_request(:get, "http://test.com/#{w}").to_return(body: "got #{w}") }
    actions = []
    builder = Class.new do
      include Fetch::Builder
      words.each do |word|
        request do |req|
          req.url = "http://test.com/#{word}"
          req.process do |body|
            actions << "process: #{body}"
          end
        end
      end
    end
    runner = Fetch::Runner.new(builder.new)
    runner.run
    assert_equal ["process: got one", "process: got two", "process: got three"], actions
  end

  def test_runner_calls_progress_callback
    words = %w{one two three}
    words.each { |w| stub_request(:get, "http://test.com/#{w}").to_return(body: "got #{w}") }
    actions = []
    builder = Class.new do
      include Fetch::Builder
      words.each do |word|
        request do |req|
          req.url = "http://test.com/#{word}"
        end
      end
    end
    runner = Fetch::Runner.new(builder.new)
    updates = []
    runner.run do
      updates << "progress"
    end
    assert_equal ["progress"] * 3, updates
  end
end