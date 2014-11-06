require "test_helper"

class BeforeFetchTest < Minitest::Test
  def test_before_fetch_runs_when_fetching
    actions = []
    klass = Class.new(Fetch::Base) do
      before_fetch { actions << "first before" }
      before_fetch { actions << "second before" }
    end
    klass.new.fetch
    assert_equal ["first before", "second before"], actions
  end
end