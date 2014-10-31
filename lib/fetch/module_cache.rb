module Fetch
  # Caches fetch modules.
  #
  #   Fetch::ModuleCache[:google][:search] # => FetchModules::Google::Search
  #   Fetch::ModuleCache[:google][:nonexistent] # => nil
  class ModuleCache
    def get(namespace, source_key, module_key)
      store[namespace][source_key][module_key]
    end

    private

    # The internal cache.
    #
    #   cache = Fetch::ModuleCache.new
    #   cache.store[:some_namespace][:some_source_key][:some_module_key]
    #   # => SomeFetchModule
    def store
      @cache ||= Hash.new do |namespace_hash, namespace_key|
        namespace_hash[namespace_key] = Hash.new do |source_hash, source_key|
          source_hash[source_key] = Hash.new do |module_hash, module_key|
            module_hash[module_key] = constantize_fetch_module(namespace_key, source_key, module_key)
          end
        end
      end
    end

    # Constantizes a fetch module from +source_key+ and +module_key+.
    def constantize_fetch_module(namespace, source_key, module_key)
      klass = Util.camelize("#{namespace}/#{source_key}/#{module_key}")
      Util.safe_constantize(klass)
    end
  end
end