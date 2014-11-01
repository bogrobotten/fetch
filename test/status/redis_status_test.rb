require "test_helper"

class RedisStatusTest < Minitest::Test
  def test_redis_status
    fetchable = OpenStruct.new(updates: [])

    klass = Class.new(Fetch::Base) do
      include Fetch::Status::Redis

      modules do
        [Class.new(Fetch::Module)] * 3
      end

      progress do
        fetchable.updates << status.progress
      end
    end

    fetcher = klass.new(fetchable)
    status = fetcher.status

    assert_nil status.started_at
    assert_equal false, status.started?

    assert_nil status.completed_at
    assert_equal false, status.completed?

    fetcher.fetch

    assert_equal [0, 33, 66, 100], fetchable.updates

    assert_kind_of Time, status.started_at
    assert_equal true, status.started?

    assert_kind_of Time, status.started_at
    assert_equal true, status.completed?
  end
end