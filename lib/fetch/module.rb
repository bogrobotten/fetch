module Fetch
  class Module
    include Callbacks
    include Async

    define_callback :fetch_if,
                    :failure,
                    :error

    def initialize(fetchable = nil)
      @fetchable = fetchable
    end

    # Whether or not the module should be used when fetching.
    # Set with `fetch_if do ... end`.
    def fetch?
      return true unless callback?(:fetch_if)
      !!fetch_if
    end

    private

    # The optional instance being fetched.
    attr_reader :fetchable
  end
end