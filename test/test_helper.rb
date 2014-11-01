require "minitest/autorun"
require "webmock/minitest"

require "fetch"

# Load support files
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

# Mocked fetcher
def MockFetcher(mods)
  Class.new(Fetch::Base) do
    modules { mods }
  end
end