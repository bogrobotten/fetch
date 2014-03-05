module Fetch
  module Configuration
    class << self
      DEFAULT_USER_AGENT = "Mozilla/5.0"
      DEFAULT_TIMEOUT = 10
      DEFAULT_RAISE_ON_ERROR = false

      # Default user agent for async fetches.
      def user_agent
        @user_agent ||= DEFAULT_USER_AGENT
      end

      attr_writer :user_agent

      # Timeout for async fetches.
      def timeout
        @timeout ||= DEFAULT_TIMEOUT
      end

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

      attr_writer :raise_on_error
    end
  end
end