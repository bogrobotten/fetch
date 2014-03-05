module Fetch
  class Base
    class << self
      attr_reader :fetchable

      def initialize(fetchable)
        @fetchable = fetchable
      end

      # Fetch modules definition
      def fetch_modules
        @fetch_modules ||= []
      end

      def fetches_with(*module_keys)
        @fetch_modules = module_keys
      end

      # Fetch sources definition
      def fetch_sources
        @fetch_sources ||= []
      end

      def fetches_from(proc_or_array)
        @fetch_sources = proc_or_array
      end

      # Callbacks
      def callbacks
        @callbacks ||= Hash.new { |h, k| h[k] = [] }
      end

      [:before_fetch, :after_fetch, :progress].each do |callback|
        define_method callback do |&block|
          callbacks[callback] << block
        end
      end

      def run_callbacks_for(callback, *args)
        callbacks[callback].each { |block| block.call(*args) }
      end

      # Cached fetch source modules.
      #
      #   Fetch::Base.fetch_source_modules[:google][:search] # => FetchModules::Google::Search
      #   Fetch::Base.fetch_source_modules[:google][:nonexistent] # => nil
      def fetch_source_modules
        @fetch_source_modules ||= Hash.new do |source_hash, source_key|
          source_hash[source_key] = Hash.new do |module_hash, module_key|
            module_hash[module_key] = constantize_fetch_module(source_key, module_key)
          end
        end
      end
    end


    # Fetch
    def begin

    end

    private

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

      def source_modules
        @source_modules ||= begin
          sources.map do |source_key|
            self.class.fetch_modules.map do |module_key|
              self.class.fetch_source_modules[source_key][module_key]
            end
          end.flatten
        end
      end

      def constantize_fetch_module(source_key, module_key)
        Fetch.config.namespaces.map do |namespace|
          "#{namespace}/#{source_key}/#{module_key}".camelize.safe_constantize
        end.compact.first
      end
  end
end