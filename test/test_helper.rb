require "minitest/autorun"
require "fetch"

# Load support files
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

# Mocked fetcher
def MockFetcher(mod)
  Class.new(Fetch::Base) do
    modules { mod }
  end
end