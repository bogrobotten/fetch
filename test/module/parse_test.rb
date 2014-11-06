require "test_helper"

class ParseTest < Minitest::Test
  def test_parsing_body
    stub_request(:get, "http://test.com/one").to_return(body: "got one")
    actions = []
    mod = Class.new(Fetch::Module) do
      request do |req|
        req.url = "http://test.com/one"
        req.parse do |body|
          "parsed(#{body})"
        end
        req.process do |body|
          actions << "process: #{body}"
        end
      end
    end
    MockFetcher(mod).new.fetch
    assert_equal ["process: parsed(got one)"], actions
  end
end
