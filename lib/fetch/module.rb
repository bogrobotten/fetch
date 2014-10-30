module Fetch
  class Module
    include Callbacks
    include Async

    define_callback :fetch_if,
                    :fetch,
                    :before_fetch,
                    :after_fetch,
                    :failed

    # Makes it possible to include +Async+ directly in subclasses.
    Async = Fetch::Async

    # The object being fetched.
    attr_reader :fetchable

    # The source being fetched from.
    attr_reader :source

    # Initializes the fetch module with a fetchable.
    def initialize(fetchable, source)
      @fetchable, @source = fetchable, source
    end

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