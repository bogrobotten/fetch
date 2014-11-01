require "test_helper"

class SimpleTest < Minitest::Test
  def test_simple_fetch
    stub_request(:get, "http://test.com/one").to_return(body: "got one")
    actions = []
    mod = Class.new(Fetch::Module) do
      include Fetch::Simple
      url { "http://test.com/one" }
      process do |body|
        actions << "process: #{body}"
      end
    end
    MockFetcher(mod).new.fetch
    assert_equal ["process: got one"], actions
  end
end
