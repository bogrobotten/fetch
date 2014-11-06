require "test_helper"

class AfterProcessTest < Minitest::Test
  def test_after_process_callback_set_in_request
    words = %w{one two}
    words.each { |w| stub_request(:get, "http://test.com/#{w}").to_return(body: "got #{w}") }
    
    stub_request(:get, "http://test.com/two").to_return(body: "got two")
    actions = []
    mod = Class.new(Fetch::Module) do
      words.each do |word|
        request do |req|
          req.url = "http://test.com/#{word}"
          req.after_process do
            actions << "after process #{word}"
          end
          req.process do |body|
            actions << "process #{word}"
          end
        end
      end
    end
    MockFetcher(mod).new.fetch
    assert_equal ["process one", "after process one", "process two", "after process two"], actions
  end

  def test_after_process_callback_scope_set_in_request
    words = %w{one two}
    words.each { |w| stub_request(:get, "http://test.com/#{w}").to_return(body: "got #{w}") }
    
    stub_request(:get, "http://test.com/two").to_return(body: "got two")
    actions = []
    mod = Class.new(Fetch::Module) do
      words.each do |word|
        request do |req|
          req.url = "http://test.com/#{word}"
          req.after_process do
            actions << "after process #{word} (#{some_instance_method})"
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
    assert_equal ["process one", "after process one (ok)", "process two", "after process two (ok)"], actions
  end

  def test_after_process_callback_set_in_module
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

      after_process do
        actions << "after process"
      end
    end
    MockFetcher(mod).new.fetch
    assert_equal ["process one", "after process", "process two", "after process"], actions
  end

  def test_after_process_callback_scope_set_in_module
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

      after_process do
        actions << "after process (#{some_instance_method})"
      end

      def some_instance_method
        "ok"
      end
    end
    MockFetcher(mod).new.fetch
    assert_equal ["process one", "after process (ok)", "process two", "after process (ok)"], actions
  end
end