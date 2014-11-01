require "test_helper"

class FetchTest < Minitest::Test
  def test_basic_fetch
    fetchable = Fetchable.new
    MockFetcher(BasicModule).new(fetchable).fetch
    assert_equal %w{before fetch after}, fetchable.actions
  end

  def test_positive_fetch_if_filter
    fetchable = Fetchable.new
    mod = Class.new(BasicModule) do
      fetch_if do
        true
      end
    end
    MockFetcher(mod).new(fetchable).fetch
    assert_includes fetchable.actions, "fetch"
  end

  def test_negative_fetch_if_filter
    fetchable = Fetchable.new
    mod = Class.new(BasicModule) do
      fetch_if do
        false
      end
    end
    MockFetcher(mod).new(fetchable).fetch
    assert !fetchable.actions.include?("fetch")
  end

  class BasicModule < Fetch::Module
    def initialize(fetchable)
      @fetchable = fetchable
    end

    before_fetch do
      @fetchable.actions << "before"
    end

    fetch do
      @fetchable.actions << "fetch"
    end

    after_fetch do
      @fetchable.actions << "after"
    end
  end

  class Fetchable
    def actions
      @actions ||= []
    end
  end
end