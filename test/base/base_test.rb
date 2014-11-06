require "test_helper"

class BaseTest < Minitest::Test
  def test_sends_fetchable_to_modules
    stub_request(:get, "https://api.github.com/users/lassebunk").to_return(body: "id: 1234")
    actions = []
    mod = Class.new(Fetch::Module) do
      request do |req|
        req.url = "https://api.github.com/users/#{fetchable.login}"
        req.process do |body|
          actions << "process: #{body}"
        end
      end
    end
    user = OpenStruct.new(login: "lassebunk")
    MockFetcher(mod).new(user).fetch
    assert_equal ["process: id: 1234"], actions
  end
end