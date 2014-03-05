require "typhoeus"
require "fetchable"

%w{
  version
  base
  module
  async
  configuration
}.each do |file|
  require "fetch/#{file}"
end

module Fetch
  class << self
    # Convenience method that returns +Fetch::Configuration+.
    def config
      Fetch::Configuration
    end

    # Yields a configuration block (+Fetch::Configuration+).
    #
    #   Fetch.configure do |config|
    #     config.user_agent = "Custom User Agent"
    #   end
    def configure(&block)
      yield config
    end
  end
end