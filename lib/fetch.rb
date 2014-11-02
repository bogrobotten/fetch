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
  builder
  runner
}.each do |file|
  require "fetch/#{file}"
end

module Fetch
  class HttpError < StandardError
    attr_reader :code, :url

    def initialize(code, url)
      @code, @url = code, url
    end

    def message
      "HTTP Error #{code}: #{url}"
    end
  end

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