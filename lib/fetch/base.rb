# Base module for fetch handlers, e.g. +ProductFetch+, +UserFetch+, etc.
module Fetch
  class Base
    include Callbacks

    # Set callbacks to be called when fetching.
    #
    #   before_fetch do
    #     # do something before fetching
    #   end
    #
    #   after_fetch do
    #     # do something after fetching
    #   end
    #
    #   progress do |progress|
    #     # update progress in percent
    #   end
    define_callback :modules,
                    :before_fetch,
                    :after_fetch,
                    :progress

    # Initialize the fetcher with optional arguments to be sent to fetch
    # modules.
    def initialize(*module_args)
      @module_args = module_args
    end

    # Begin fetching.
    # Will run synchronous fetches first and async fetches afterwards.
    # Updates progress when each module finishes its fetch.
    def fetch
      requests = instantiate_modules.select(&:fetch?).map(&:requests).flatten

      total, done = requests.size, 0
      update_progress(total, done)

      before_fetch

      backend.new(requests).run do
        update_progress(total, done += 1)
      end

      after_fetch
    end

    private

    # Holds the arguments to be sent to fetch modules.
    attr_reader :module_args

    # Array of instantiated fetch modules.
    def instantiate_modules
      Array(modules).map { |m| m.new(*module_args) }
    end

    # Updates progress with a percentage calculated from +total+ and +done+.
    def update_progress(total, done)
      percentage = total.zero? ? 100 : ((done.to_f / total) * 100).to_i
      progress(percentage)
    end

    def backend
      Fetch.config.backend
    end
  end
end