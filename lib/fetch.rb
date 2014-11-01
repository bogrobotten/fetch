require "typhoeus"

%w{
  version
  callbacks
  base
  request
  async
  simple
  module
  backend
  configuration
}.each do |file|
  require "fetch/#{file}"
end

module Fetch
  class HttpError < StandardError; end
  class ProcessError < StandardError; end

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