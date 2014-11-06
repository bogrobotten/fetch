require "test_helper"

class AfterFetchTest < Minitest::Test
  def test_after_fetch_runs_when_fetching
    actions = []
    klass = Class.new(Fetch::Base) do
      after_fetch { actions << "first after" }
      after_fetch { actions << "second after" }
    end
    klass.new.fetch
    assert_equal ["first after", "second after"], actions
  end
end