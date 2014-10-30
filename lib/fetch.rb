require "active_support"
require "typhoeus"

%w{
  version
  util
  callbacks
  base
  async
  module
  configuration
}.each do |file|
  require "fetch/#{file}"
end

require "fetchable"

module Fetch
  class << self
    # Returns a configuration object.
    def config
      @config ||= Configuration.new
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