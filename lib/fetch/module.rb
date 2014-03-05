module Fetch
  class Module
    attr_reader :fetchable

    def initialize(fetchable)
      @fetchable = fetchable
    end

    def fetch?
      true
    end

    def fetch
      raise "#{self.class.name} must implement either #fetch, or #url and #response for async fetch."
    end

    def before_fetch
    end

    def after_fetch
    end

    def async?
      respond_to?(:url) && respond_to?(:response)
    end
  end
end