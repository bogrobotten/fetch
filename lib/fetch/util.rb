module Fetch
  # Contains a set of utility methods for use inside Fetch.
  module Util
    # Converts an underscored name to camelized version for use with
    # constantize.
    #
    #   Util.camelize("fetch_modules/git_hub/user_info_fetch")
    #   # => "FetchModules::GitHub::UserInfoFetch"
    def self.camelize(underscored)
      underscored.gsub(/(^|[\/_])./, &:upcase).gsub("_", "").gsub("/", "::")
    end

    # Constantizes a class name.
    #
    #   Util.constantize("FetchModules::GitHub::UserInfoFetch")
    #   # => FetchModules::GitHub::UserInfoFetch
    #
    #   Util.constantize("Some::Nonexistent::Class")
    #   # => NameError
    def self.constantize(name)
      name.split("::").inject(Kernel, &:const_get)
    end

    # Constantizes a class name, returning +nil+ if the class doesn't exist.
    #
    #   Util.safe_constantize("FetchModules::GitHub::UserInfoFetch")
    #   # => FetchModules::GitHub::UserInfoFetch
    #
    #   Util.safe_constantize("Some::Nonexistent::Class")
    #   # => nil
    def self.safe_constantize(name)
      constantize(name)
    rescue NameError
      nil
    end
  end
end