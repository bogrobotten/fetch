require "test_helper"

class InitTest < Minitest::Test
  def test_initializes_modules
    stub_request(:get, "https://api.github.com/users/lassebunk").to_return(body: "id: 1234")
    actions = []
    mod = Class.new(Fetch::Module) do
      attr_reader :email, :login
      def initialize(email, login)
        @email, @login = email, login
      end
      request do |req|
        req.url = "https://api.github.com/users/#{login}"
        req.process do |body|
          actions << "process: #{body} (email: #{email}, login: #{login})"
        end
      end
    end

    klass = Class.new(MockFetcher(mod)) do
      alias :user :fetchable
      init do |klass|
        klass.new(user.email, user.login)
      end
    end

    user = OpenStruct.new(email: "lasse@bogrobotten.dk", login: "lassebunk")
    klass.new(user).fetch
    assert_equal ["process: id: 1234 (email: lasse@bogrobotten.dk, login: lassebunk)"], actions
  end

  def test_init_runs_only_once
    actions = []
    mod = Class.new(Fetch::Module)
    klass = Class.new(MockFetcher(mod)) do
      init do |klass|
        this_cant_be_run!
      end
      init do |klass|
        actions << "got init"
        klass.new
      end
    end
    klass.new.fetch
    assert_equal ["got init"], actions
  end
end