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
    define_callback :sources,
                    :modules,
                    :before_fetch,
                    :after_fetch,
                    :progress

    attr_reader :fetchable

    # Initialize the fetcher with a fetchable instance.
    def initialize(fetchable)
      @fetchable = fetchable
    end

    # Begin fetching.
    # Will run synchronous fetches first and async fetches afterwards.
    # Updates progress when each module finishes its fetch.
    def fetch
      @total_count = fetch_modules.count
      @completed_count = 0

      update_progress
      before_fetch

      hydra = Typhoeus::Hydra.new

      fetch_modules.each do |fetch_module|
        if fetch_module.before_filter == false
          update_progress(true)
        else
          fetch_module.before_fetch
          if fetch_module.async?
            request = fetch_module.request do
              fetch_module.after_fetch
              update_progress(true)
            end
            Array(request).each { |request| hydra.queue request }
          else
            fetch_module.fetch
            fetch_module.after_fetch
            update_progress(true)
          end
        end
      end

      hydra.run

      after_fetch
    end

    private

    # Cached fetch source modules.
    #
    #   Fetch::Base.module_cache[:google][:search] # => FetchModules::Google::Search
    #   Fetch::Base.module_cache[:google][:nonexistent] # => nil
    def self.module_cache
      @module_cache ||= Hash.new do |source_hash, source_key|
        source_hash[source_key] = Hash.new do |module_hash, module_key|
          module_hash[module_key] = constantize_fetch_module(source_key, module_key)
        end
      end
    end

    # Constantizes a fetch module from +source_key+ and +module_key+.
    def self.constantize_fetch_module(source_key, module_key)
      Fetch.config.namespaces.map do |namespace|
        "#{namespace}/#{source_key}/#{module_key}".camelize.safe_constantize
      end.compact.first
    end

    # Updates progress.
    def update_progress(one_completed = false)
      @completed_count += 1 if one_completed
      progress(progress_percent)
    end

    # Returns the fetch progress in percent.
    def progress_percent
      return 100 if @total_count == 0
      ((@completed_count.to_f / @total_count) * 100).to_i
    end

    # Returns an array on instantiated fetch modules.
    def fetch_modules
      @fetch_modules ||= begin
        Array(sources).map do |source_key|
          Array(modules).map do |module_key|
            self.class.module_cache[source_key][module_key].try(:new, fetchable)
          end
        end.flatten.compact
      end
    end
  end
end