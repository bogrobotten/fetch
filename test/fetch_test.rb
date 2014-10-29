require "test_helper"

class FetchTest < Minitest::Test
  def test_async_fetch
    user = User.find_by_login!("lassebunk")
    user.fetch.begin

    assert_equal 106146, user.github_id
    assert_equal 1234, user.some_other_id
  end
end