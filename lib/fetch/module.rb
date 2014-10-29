module Fetch
  class Module
    # Makes it possible to include +Async+ directly in subclasses.
    Async = Fetch::Async

    attr_reader :fetchable

    # Initializes the fetch module with a fetchable.
    def initialize(fetchable)
      @fetchable = fetchable
    end

    # Can be overridden to return whether to fetch (+true which is default),
    # or +false+ to skip the fetch.
    def fetch?
      true
    end

    # Method to be run when fetching with this module.
    # Must be overridden unless doing async fetches.
    def fetch
      raise "#{self.class.name} must either implement #fetch or `include Fetch::Async` to do async fetch."
    end

    # Can be overridden to do custom logic before fetching.
    def before_fetch
    end

    # Can be overridden to do custom logic after fetching.
    def after_fetch
    end

    # Whether this module is an async fetch module.
    # Is set to true when including +Fetch::Async+.
    def async?
      false
    end

    # Handle fetch failures.
    # Can take either a message string or exception.
    # If given an exception, for example if a fetch module raises an exception,
    # it will raise the exception if +config.raise_on_error+ is set to true.
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