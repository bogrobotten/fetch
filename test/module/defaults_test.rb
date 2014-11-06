require "test_helper"

class DefaultsTest < Minitest::Test
  def test_simple_fetch
    words = %w{one two}
    words.each { |w| stub_request(:get, "http://test.com/#{w}").to_return(body: "got #{w}") }
    actions = []
    mod = Class.new(Fetch::Module) do
      defaults do |req|
        req.process do |body|
          actions << "process: #{body}"
        end
      end
      words.each do |word|
        request do |req|
          req.url = "http://test.com/#{word}"
        end
      end
    end
    MockFetcher(mod).new.fetch
    assert_equal ["process: got one", "process: got two"], actions
  end
end
