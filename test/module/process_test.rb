require "test_helper"

class ProcessTest < Minitest::Test
  def test_process_block_scope
    stub_request(:get, "http://test.com/one").to_return(body: "got one")
    actions = []
    mod = Class.new(Fetch::Module) do
      request do |req|
        req.url = "http://test.com/one"
        req.process do |body|
          actions << "body: #{body} (#{some_instance_method})"
        end
      end

      def some_instance_method
        "it worked"
      end
    end
    MockFetcher(mod).new.fetch
    assert_equal ["body: got one (it worked)"], actions
  end
end