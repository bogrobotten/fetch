require "test_helper"

class FetchTest < Minitest::Test
  def test_basic_fetch
    fetchable = OpenStruct.new(callbacks: [])

    mod = Class.new(Fetch::Module) do
      def initialize(fetchable)
        @fetchable = fetchable
      end

      before_fetch do
        @fetchable.callbacks << "before"
      end

      fetch do
        @fetchable.callbacks << "fetch"
      end

      after_fetch do
        @fetchable.callbacks << "after"
      end
    end

    klass = Class.new(Fetch::Base) do
      modules { mod }
    end

    klass.new(fetchable).fetch

    assert_equal %w{before fetch after}, fetchable.callbacks
  end
end