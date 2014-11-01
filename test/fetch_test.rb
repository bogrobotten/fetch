require "test_helper"

class FetchTest < Minitest::Test
  def setup
    Fetch.configure do |config|
      config.raise_on_error = true
    end
  end
end