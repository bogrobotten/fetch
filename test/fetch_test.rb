require "test_helper"

class FetchTest < Minitest::Test
  def test_basic_fetch
    fetchable = Fetchable.new
    MockFetcher(BasicModule).new(fetchable).fetch

    assert_equal %w{before fetch after}, fetchable.actions
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