require "test_helper"

class JsonTest < Minitest::Test
  def test_parsing_json
    stub_request(:get, "http://api.test.com/user").to_return(body: '{"id":123}')
    actions = []
    mod = Class.new(Fetch::Module) do
      include Fetch::JSON
      request do |req|
        req.url = "http://api.test.com/user"
        req.process do |json|
          actions << "user id: #{json['id'].inspect}"
        end
      end
    end
    MockFetcher(mod).new.fetch
    assert_equal ["user id: 123"], actions
  end
end
