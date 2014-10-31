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
    define_callback :namespaces,
                    :sources,
                    :modules,
                    :before_fetch,
                    :after_fetch,
                    :progress

    attr_reader :fetchable

    # Initialize the fetcher with a fetchable instance.
    def initialize(fetchable)
      @fetchable = fetchable
    end

    # Fetch key of the fetch, taken from the fetchable.
    def fetch_key
      fetchable.fetch_key
    end

    # Begin fetching.
    # Will run synchronous fetches first and async fetches afterwards.
    # Updates progress when each module finishes its fetch.
    def fetch
      @total_count = fetch_modules.count
      @completed_count = 0

      update_progress
      before_fetch
      fetchable.before_fetch

      hydra = Typhoeus::Hydra.new

      fetch_modules.each do |fetch_module|
        fetch_module.before_fetch
        if fetch_module.async?
          fetch_module.typhoeus_requests do
            fetch_module.after_fetch
            update_progress(true)
          end.each do |request|
            hydra.queue(request)
          end
        else
          fetch_module.fetch
          fetch_module.after_fetch
          update_progress(true)
        end
      end

      hydra.run

      fetchable.after_fetch
      after_fetch
    end

    private

    def self.inherited(base)
      super
      base.instance_variable_set(:@namespaces, @namespaces.dup) unless @namespaces.nil?
    end

    # Convenience method for setting a single namespace.
    #
    #   namespace :sites
    #   namespaces # => [:sites]
    def self.namespace(name)
      namespaces(name)
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
        Array(namespaces).map do |namespace|
          Array(sources).map do |source|
            source_key = extract_source_key(source)
            Array(modules).map do |module_key|
              Fetch.module_cache.get(namespace, source_key, module_key).try(:new, fetchable, source)
            end
          end
        end.flatten.compact.select(&:fetch?)
      end
    end

    # Extracts a source key from the given source.
    # +source+ can be a +String+, +Symbol+, or an instance that responds to +fetch_key+.
    def extract_source_key(source)
      case source
      when Symbol then source
      when String then source.to_sym
      else source.fetch_key.to_sym
      end
    end
  end
end