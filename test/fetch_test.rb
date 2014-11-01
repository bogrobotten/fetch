require "test_helper"

class FetchTest < Minitest::Test
  def test_fetch_using_get
    stub_request(:get, "http://test.com/one").to_return(body: "got one")
    actions = []
    mod = Class.new(Fetch::Module) do
      request do |req|
        req.url = "http://test.com/one"
        req.process do |body|
          actions << "body: #{body}"
        end
      end
    end
    MockFetcher(mod).new.fetch
    assert_equal ["body: got one"], actions
  end

  def test_fetch_using_post
    stub_request(:post, "http://test.com/create").to_return(->(req) { { body: "you posted: #{req.body}" } })
    actions = []
    mod = Class.new(Fetch::Module) do
      request do |req|
        req.method = :post
        req.url = "http://test.com/create"
        req.body = { one: 1, two: 2 }
        req.process do |body|
          actions << "body: #{body}"
        end
      end
    end
    MockFetcher(mod).new.fetch
    assert_equal ["body: you posted: one=1&two=2"], actions
  end

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

  def test_positive_fetch_if_filter
    stub_request(:get, "http://test.com/one").to_return(body: "got one")
    actions = []
    mod = Class.new(Fetch::Module) do
      fetch_if { true }

      request do |req|
        req.url = "http://test.com/one"
        req.process do |body|
          actions << "body: #{body}"
        end
      end
    end
    MockFetcher(mod).new.fetch
    assert_equal ["body: got one"], actions
  end

  def test_negative_fetch_if_filter
    stub_request(:get, "http://test.com/one").to_return(body: "got one")
    actions = []
    mod = Class.new(Fetch::Module) do
      fetch_if { false }

      request do |req|
        req.url = "http://test.com/one"
        req.process do |body|
          actions << "body: #{body}"
        end
      end
    end
    MockFetcher(mod).new.fetch
    assert_equal [], actions
  end

  def test_nil_fetch_if_filter
    stub_request(:get, "http://test.com/one").to_return(body: "got one")
    actions = []
    mod = Class.new(Fetch::Module) do
      fetch_if { nil }

      request do |req|
        req.url = "http://test.com/one"
        req.process do |body|
          actions << "body: #{body}"
        end
      end
    end
    MockFetcher(mod).new.fetch
    assert_equal [], actions
  end

  def test_if_filter_scope
    stub_request(:get, "http://test.com/one").to_return(body: "got one")
    actions = []
    mod = Class.new(Fetch::Module) do
      fetch_if { should_i_fetch? }

      request do |req|
        req.url = "http://test.com/one"
        req.process do |body|
          actions << "body: #{body}"
        end
      end

      def should_i_fetch?
        true
      end
    end
    MockFetcher(mod).new.fetch
    assert_equal ["body: got one"], actions
  end

  def test_multiple_requests
    words = %w{one two three}
    words.each { |w| stub_request(:get, "http://test.com/#{w}").to_return(body: "got #{w}") }
    actions = []

    mod = Class.new(Fetch::Module) do
      words.each do |w|
        request do |req|
          req.url = "http://test.com/#{w}"
          req.process do |body|
            actions << "body: #{body}"
          end
        end
      end
    end
    MockFetcher(mod).new.fetch
    assert_equal ["body: got one", "body: got two", "body: got three"], actions
  end

  def test_unhandled_http_failure
    stub_request(:get, "http://test.com/one").to_return(body: "something went wrong", status: 500)
    actions = []
    mod = Class.new(Fetch::Module) do
      request do |req|
        req.url = "http://test.com/one"
        req.process do |body|
          actions << "body: #{body}"
        end
      end
    end
    assert_equal [], actions
  end

  def test_http_failure_handled_in_request
    stub_request(:get, "http://test.com/one").to_return(body: "something went wrong", status: 500)
    actions = []
    mod = Class.new(Fetch::Module) do
      request do |req|
        req.url = "http://test.com/one"
        req.failure do |code|
          actions << "handled error #{code}"
        end
        req.process do |body|
          actions << "body: #{body}"
        end
      end
    end
    MockFetcher(mod).new.fetch
    assert_equal ["handled error 500"], actions
  end

  def test_http_failure_scope_handled_in_request
    stub_request(:get, "http://test.com/one").to_return(body: "something went wrong", status: 500)
    actions = []
    mod = Class.new(Fetch::Module) do
      request do |req|
        req.url = "http://test.com/one"
        req.failure do |code|
          actions << "handled error #{code} (#{some_instance_method})"
        end
        req.process do |body|
          actions << "body: #{body}"
        end
      end

      def some_instance_method
        "it worked"
      end
    end
    MockFetcher(mod).new.fetch
    assert_equal ["handled error 500 (it worked)"], actions
  end

  def test_http_failure_handled_in_module
    stub_request(:get, "http://test.com/one").to_return(body: "something went wrong", status: 500)
    actions = []
    mod = Class.new(Fetch::Module) do
      request do |req|
        req.url = "http://test.com/one"
        req.process do |body|
          actions << "body: #{body}"
        end
      end
      failure do |code|
        actions << "handled error #{code}"
      end
    end
    MockFetcher(mod).new.fetch
    assert_equal ["handled error 500"], actions
  end

  def test_http_failure_scope_handled_in_module
    stub_request(:get, "http://test.com/one").to_return(body: "something went wrong", status: 500)
    actions = []
    mod = Class.new(Fetch::Module) do
      request do |req|
        req.url = "http://test.com/one"
        req.process do |body|
          actions << "body: #{body}"
        end
      end
      failure do |code|
        actions << "handled error #{code} (#{some_instance_method})"
      end
      def some_instance_method
        "it worked"
      end
    end
    MockFetcher(mod).new.fetch
    assert_equal ["handled error 500 (it worked)"], actions
  end

  def test_unhandled_process_error
    stub_request(:get, "http://test.com/one").to_return(body: "ok")
    actions = []
    mod = Class.new(Fetch::Module) do
      request do |req|
        req.url = "http://test.com/one"
        req.process do |body|
          this_wont_work
        end
      end
    end
    assert_raises NameError do
      MockFetcher(mod).new.fetch
    end
  end

  def test_process_error_handled_in_request
    stub_request(:get, "http://test.com/one").to_return(body: "ok")
    actions = []
    mod = Class.new(Fetch::Module) do
      request do |req|
        req.url = "http://test.com/one"
        req.error do |e|
          actions << "handled #{e.class.name}"
        end
        req.process do |body|
          this_wont_work
        end
      end
    end
    MockFetcher(mod).new.fetch
    assert_equal ["handled NameError"], actions
  end

  def test_process_error_scope_handled_in_request
    stub_request(:get, "http://test.com/one").to_return(body: "ok")
    actions = []
    mod = Class.new(Fetch::Module) do
      request do |req|
        req.url = "http://test.com/one"
        req.error do |e|
          actions << "handled #{e.class.name} (#{some_instance_method})"
        end
        req.process do |body|
          this_wont_work
        end
      end

      def some_instance_method
        "it worked"
      end
    end
    MockFetcher(mod).new.fetch
    assert_equal ["handled NameError (it worked)"], actions
  end

  def test_process_error_handled_in_module
    stub_request(:get, "http://test.com/one").to_return(body: "ok")
    actions = []
    mod = Class.new(Fetch::Module) do
      request do |req|
        req.url = "http://test.com/one"
        req.process do |body|
          this_wont_work
        end
      end
      error do |e|
        actions << "handled #{e.class.name}"
      end
    end
    MockFetcher(mod).new.fetch
    assert_equal ["handled NameError"], actions
  end

  def test_process_error_scope_handled_in_module
    stub_request(:get, "http://test.com/one").to_return(body: "ok")
    actions = []
    mod = Class.new(Fetch::Module) do
      request do |req|
        req.url = "http://test.com/one"
        req.process do |body|
          this_wont_work
        end
      end
      error do |e|
        actions << "handled #{e.class.name} (#{some_instance_method})"
      end
      def some_instance_method
        "it worked"
      end
    end
    MockFetcher(mod).new.fetch
    assert_equal ["handled NameError (it worked)"], actions
  end

  def test_progress_with_single_module
    stub_request(:get, "http://test.com/one").to_return(body: "got one")

    mod = Class.new(Fetch::Module) do
      3.times do
        request do |req|
          req.url = "http://test.com/one"
        end
      end
    end

    updates = []

    klass = Class.new(MockFetcher(mod)) do
      progress do |percent|
        updates << percent
      end
    end

    klass.new.fetch
    assert_equal [0, 33, 66, 100], updates
  end

  def test_progress_with_multiple_modules
    stub_request(:get, "http://test.com/one").to_return(body: "got one")

    mods = 3.times.map do
      Class.new(Fetch::Module) do
        2.times do
          request do |req|
            req.url = "http://test.com/one"
          end
        end
      end
    end

    updates = []

    klass = Class.new(MockFetcher(mods)) do
      progress do |percent|
        updates << percent
      end
    end

    klass.new.fetch
    assert_equal [0, 16, 33, 50, 66, 83, 100], updates
  end

  def test_progress_with_http_failure
    stub_request(:get, "http://test.com/one").to_return(body: "something went wrong", status: 500)
    updates = []
    mods = 3.times.map do
      Class.new(Fetch::Module) do
        request do |req|
          req.url = "http://test.com/one"
        end
      end
    end
    klass = Class.new(MockFetcher(mods)) do
      progress do |percent|
        updates << percent
      end
    end

    klass.new.fetch
    assert_equal [0, 33, 66, 100], updates
  end

  def test_progress_with_handled_process_error
    stub_request(:get, "http://test.com/one").to_return(body: "ok")
    updates = []
    mods = 3.times.map do
      Class.new(Fetch::Module) do
        request do |req|
          req.url = "http://test.com/one"
          req.process do |body|
            wont_work
          end
          req.error { }
        end
      end
    end
    klass = Class.new(MockFetcher(mods)) do
      progress do |percent|
        updates << percent
      end
    end

    klass.new.fetch
    assert_equal [0, 33, 66, 100], updates
  end
end
