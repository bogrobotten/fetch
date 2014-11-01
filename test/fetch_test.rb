require "test_helper"

class FetchTest < Minitest::Test
  def test_basic_fetch
    actions = []
    mod = Class.new(Fetch::Module) do
      before_fetch { actions << "before" }
      fetch { actions << "fetch" }
      after_fetch { actions << "after" }
    end
    MockFetcher(mod).new.fetch
    assert_equal %w{before fetch after}, actions
  end

  def test_positive_fetch_if_filter
    actions = []
    mod = Class.new(Fetch::Module) do
      fetch_if { true }
      before_fetch { actions << "before" }
      fetch { actions << "fetch" }
      after_fetch { actions << "after" }
    end
    MockFetcher(mod).new.fetch
    assert_equal %w{before fetch after}, actions
  end

  def test_negative_fetch_if_filter
    actions = []
    mod = Class.new(Fetch::Module) do
      fetch_if { false }
      before_fetch { actions << "before" }
      fetch { actions << "fetch" }
      after_fetch { actions << "after" }
    end
    MockFetcher(mod).new.fetch
    assert_equal [], actions
  end

  def test_progress
    updates = []
    mods = [Fetch::Module] * 3
    klass = Class.new(MockFetcher(mods)) do
      progress do |percent|
        updates << percent
      end
    end
    klass.new.fetch
    assert_equal [0, 33, 66, 100], updates
  end
end