module Fetch
  class Module
    include Callbacks

    define_callback :before_filter,
                    :fetch,
                    :before_fetch,
                    :after_fetch,
                    :failed

    before_filter { true }

    # Makes it possible to include +Async+ directly in subclasses.
    Async = Fetch::Async

    # The object being fetched.
    attr_reader :fetchable

    # Initializes the fetch module with a fetchable.
    def initialize(fetchable)
      @fetchable = fetchable
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
    failed do |message_or_exception|
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