require "active_support"
require "typhoeus"

%w{
  version
  util
  callbacks
  base
  request
  async
  module
  configuration
  progress
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

    def module_cache
      @module_cache ||= ModuleCache.new
    end
  end
end