module Fetch
  class Module
    include Callbacks
    include Async

    define_callback :fetch_if,
                    :fetch,
                    :before_fetch,
                    :after_fetch,
                    :failed

    # Whether or not the module should be used when fetching.
    # Set with `fetch_if do ... end`.
    def fetch?
      return true unless callback?(:fetch_if)
      !!fetch_if
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