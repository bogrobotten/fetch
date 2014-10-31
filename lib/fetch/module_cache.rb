module Fetch
  # Caches fetch module classes.
  #
  #   Fetch.module_cache.fetch("fetch_modules/github/user_info_fetch")
  #   # => FetchModules::Github::UserInfoFetch
  #
  #   Fetch.module_cache.fetch("some/nonexistent/module")
  #   # => nil
  class ModuleCache
    def fetch(path)
      path = path.join("/")
      store[path]
    end

    private

    # The internal cache store.
    def store
      @store ||= Hash.new do |store, path|
        store[path] = constantize(path)
      end
    end

    # Constantizes a fetch module from the given +path+.
    def constantize(path)
      klass = Util.camelize(path)
      Util.safe_constantize(klass)
    end
  end
end