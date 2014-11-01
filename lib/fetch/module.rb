module Fetch
  class Module
    include Callbacks
    include Async

    define_callback :fetch_if,
                    :failed

    # Whether or not the module should be used when fetching.
    # Set with `fetch_if do ... end`.
    def fetch?
      return true unless callback?(:fetch_if)
      !!fetch_if
    end
  end
end