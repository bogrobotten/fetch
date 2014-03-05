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
    def config
      Fetch::Configuration
    end

    def configure(&block)
      yield config
    end
  end
end