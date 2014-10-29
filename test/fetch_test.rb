require "test_helper"

class FetchTest < Minitest::Test
  def setup
    Fetch.configure do |config|
      config.raise_on_error = true
      config.namespace = "sites"
    end
  end

  def test_async_fetch
    user = User.find_by_login!("lassebunk")
    user.fetch.begin

    assert_equal 662377014, user.facebook_id
    assert_equal 106146, user.github_id
    assert_equal 1234, user.some_other_id
  end
end