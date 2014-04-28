module Fetch
  module Configuration
    class << self
      DEFAULT_USER_AGENT = "Mozilla/5.0"
      DEFAULT_TIMEOUT = 10
      DEFAULT_RAISE_ON_ERROR = false
      DEFAULT_NAMESPACES = ["fetch_sources"]

      # User agent for async fetches.
      # Default is 'Mozilla/5.0'.
      def user_agent
        @user_agent ||= DEFAULT_USER_AGENT
      end

      # Sets user agent for async fetches.
      attr_writer :user_agent

      # Timeout for async fetches.
      # Default is 10 seconds.
      def timeout
        @timeout ||= DEFAULT_TIMEOUT
      end

      # Sets timeout for async fetches.
      attr_writer :timeout

      # Whether to raise exception on fetch error. Default is +false+.
      # In Rails, errors will be raised in the development and test environments,
      # but not in other environments.
      def raise_on_error
        return @raise_on_error if defined?(@raise_on_error)
        @raise_on_error = if defined?(Rails.env)
          %w{development test}.include?(Rails.env)
        else
          DEFAULT_RAISE_ON_ERROR
        end
      end

      # Sets whether to raise exception on fetch error.
      attr_writer :raise_on_error

      # Namespaces in which to look for fetch modules.
      # Default is +["fetch_modules"]+.
      def namespaces
        @namespaces ||= DEFAULT_NAMESPACES
      end

      # Sets namespaces in which to look for fetch modules.
      attr_writer :namespaces

      # Convenience method for defining a single namespace that contains fetch modules.
      def namespace=(value)
        self.namespaces = [value]
      end
    end
  end
end