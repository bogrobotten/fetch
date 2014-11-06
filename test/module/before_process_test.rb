require "test_helper"

class BeforeProcessTest < Minitest::Test
  def test_before_process_callback_set_in_request
    words = %w{one two}
    words.each { |w| stub_request(:get, "http://test.com/#{w}").to_return(body: "got #{w}") }
    
    stub_request(:get, "http://test.com/two").to_return(body: "got two")
    actions = []
    mod = Class.new(Fetch::Module) do
      words.each do |word|
        request do |req|
          req.url = "http://test.com/#{word}"
          req.before_process do
            actions << "before process #{word}"
          end
          req.process do |body|
            actions << "process #{word}"
          end
        end
      end
    end
    MockFetcher(mod).new.fetch
    assert_equal ["before process one", "process one", "before process two", "process two"], actions
  end

  def test_before_process_callback_scope_set_in_request
    words = %w{one two}
    words.each { |w| stub_request(:get, "http://test.com/#{w}").to_return(body: "got #{w}") }
    
    stub_request(:get, "http://test.com/two").to_return(body: "got two")
    actions = []
    mod = Class.new(Fetch::Module) do
      words.each do |word|
        request do |req|
          req.url = "http://test.com/#{word}"
          req.before_process do
            actions << "before process #{word} (#{some_instance_method})"
          end
          req.process do |body|
            actions << "process #{word}"
          end
        end
      end
      def some_instance_method
        "ok"
      end
    end
    MockFetcher(mod).new.fetch
    assert_equal ["before process one (ok)", "process one", "before process two (ok)", "process two"], actions
  end

  def test_before_process_callback_set_in_module
    words = %w{one two}
    words.each { |w| stub_request(:get, "http://test.com/#{w}").to_return(body: "got #{w}") }
    
    stub_request(:get, "http://test.com/two").to_return(body: "got two")
    actions = []
    mod = Class.new(Fetch::Module) do
      words.each do |word|
        request do |req|
          req.url = "http://test.com/#{word}"
          req.process do |body|
            actions << "process #{word}"
          end
        end
      end

      before_process do
        actions << "before process"
      end
    end
    MockFetcher(mod).new.fetch
    assert_equal ["before process", "process one", "before process", "process two"], actions
  end

  def test_before_process_callback_scope_set_in_module
    words = %w{one two}
    words.each { |w| stub_request(:get, "http://test.com/#{w}").to_return(body: "got #{w}") }
    
    stub_request(:get, "http://test.com/two").to_return(body: "got two")
    actions = []
    mod = Class.new(Fetch::Module) do
      words.each do |word|
        request do |req|
          req.url = "http://test.com/#{word}"
          req.process do |body|
            actions << "process #{word}"
          end
        end
      end

      before_process do
        actions << "before process (#{some_instance_method})"
      end

      def some_instance_method
        "ok"
      end
    end
    MockFetcher(mod).new.fetch
    assert_equal ["before process (ok)", "process one", "before process (ok)", "process two"], actions
  end
end