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
    define_callback :before_fetch,
                    :after_fetch,
                    :progress

    class << self
      # Array of fetch module keys to be used when fetching.
      # Can be set using +fetches_with+.
      def fetch_modules
        @fetch_modules ||= []
      end

      # Sets which fetch modules to use when fetching.
      #
      #   fetches_with :user_info_fetch, :avatar_fetch
      def fetches_with(*module_keys)
        @fetch_modules = module_keys
      end

      # Array of fetch sources to use when fetching.
      def fetch_sources
        @fetch_sources ||= []
      end

      # Sets which fetch sources to use when fetching.
      #
      #   fetches_from [:github, :twitter, :gravatar]
      def fetches_from(proc_or_array)
        @fetch_sources = proc_or_array
      end

      # Cached fetch source modules.
      #
      #   Fetch::Base.module_cache[:google][:search] # => FetchModules::Google::Search
      #   Fetch::Base.module_cache[:google][:nonexistent] # => nil
      def module_cache
        @module_cache ||= Hash.new do |source_hash, source_key|
          source_hash[source_key] = Hash.new do |module_hash, module_key|
            module_hash[module_key] = constantize_fetch_module(source_key, module_key)
          end
        end
      end

      private

      def constantize_fetch_module(source_key, module_key)
        Fetch.config.namespaces.map do |namespace|
          "#{namespace}/#{source_key}/#{module_key}".camelize.safe_constantize
        end.compact.first
      end
    end

    attr_reader :fetchable

    def initialize(fetchable)
      @fetchable = fetchable
    end

    # Begin fetching.
    # Will run synchronous fetches first and async fetches afterwards.
    # Updates progress when each module finishes its fetch.
    def begin
      @total_count = fetch_modules.count
      @completed_count = 0

      update_progress
      callback(:before_fetch)

      hydra = Typhoeus::Hydra.new

      fetch_modules.each do |fetch_module|
        if fetch_module.fetch?
          fetch_module.before_fetch
          if fetch_module.async?
            request = fetch_module.request do
              fetch_module.after_fetch
              update_progress true
            end
            Array(request).each { |request| hydra.queue request }
          else
            fetch_module.fetch
            fetch_module.after_fetch
            update_progress true
          end
        else
          update_progress true
        end
      end

      hydra.run

      callback(:after_fetch)
    end

    private

      def update_progress(one_completed = false)
        @completed_count += 1 if one_completed
        callback(:progress, progress)
      end

      def progress
        return 100 if @total_count == 0
        ((@completed_count.to_f / @total_count) * 100).to_i
      end

      def sources
        @sources ||= begin
          sources = self.class.fetch_sources
          case sources
          when Array then sources
          when Proc then instance_eval(&:sources)
          else raise "Unknown fetch sources #{sources.inspect}"
          end
        end
      end

      def fetch_modules
        @fetch_modules ||= begin
          sources.map do |source_key|
            self.class.fetch_modules.map do |module_key|
              self.class.module_cache[source_key][module_key].try(:new, fetchable)
            end
          end.flatten.compact
        end
      end
  end
end