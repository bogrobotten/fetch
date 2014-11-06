require "test_helper"

class LoadTest < Minitest::Test
  def test_loading_modules
    %w{one two}.each { |w| stub_request(:get, "http://test.com/#{w}").to_return(body: "got #{w}") }
    actions = []
    mod1 = Class.new(Fetch::Module) do
      request do |req|
        req.url = "http://test.com/one"
        req.process do |body|
          actions << "process: #{body}"
        end
      end
    end
    mod2 = Class.new(Fetch::Module) do
      request do |req|
        req.url = "http://test.com/two"
        req.process do |body|
          actions << "process: #{body}"
        end
      end
    end
    klass = Class.new(Fetch::Base) do
      modules :one, :two

      load do |mods|
        actions << "got #{mods.inspect}"
        [mod1, mod2]
      end
    end
    klass.new.fetch

    assert_equal ["got [:one, :two]", "process: got one", "process: got two"], actions
  end

  def test_only_last_load_callback_is_called
    actions = []
    mod = Class.new(Fetch::Module)
    klass = Class.new(Fetch::Base) do
      load do |mods|
        this_cant_be_run!
      end
      load do |mods|
        actions << "got last callback"
        [mod]
      end
    end
    klass.new.fetch

    assert_equal ["got last callback"], actions
  end
end