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
      raise "#{self.class.name} must either implement #fetch or `include Fetch::Async` to do async fetch."
    end

    def before_fetch
    end

    def after_fetch
    end

    def async?
      false
    end

    def failed(message_or_exception)
      case message_or_exception
      when Exception
        if Fetch.config.raise_on_error
          raise message_or_exception
        else
          failed message_or_exception.message
        end
      else
        # TODO: Log message
      end
    end
  end
end