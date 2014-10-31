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
      store[path] ||= constantize(path)
    end

    private

    # The internal cache store.
    def store
      @store ||= {}
    end

    # Constantizes a fetch module from the given +path+.
    def constantize(path)
      klass = Util.camelize(path)
      Util.safe_constantize(klass)
    end
  end
end