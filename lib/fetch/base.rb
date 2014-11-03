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
                    :load,
                    :init,
                    :before_fetch,
                    :after_fetch,
                    :progress

    def initialize(fetchable = nil)
      @fetchable = fetchable
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

      true
    end

    private

    # The optional instance being fetched.
    attr_reader :fetchable

    # Array of instantiated fetch modules.
    def instantiate_modules
      mods = Array(modules)
      mods = load!(mods) if callback?(:load)
      Array(mods).map do |klass|
        init(klass) || klass.new(fetchable)
      end
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