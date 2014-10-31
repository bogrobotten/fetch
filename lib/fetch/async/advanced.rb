module Fetch
  module Async
    module Advanced
      def self.included(base)
        base.define_callback :request
      end

      # Returns +true+ if a URL has been defined using `url do ... end`.
      def async?
        super || callback?(:request)
      end

      # Requests to be made.
      def requests
        if callback?(:request)
          req = Request.new
          request(req)
          super + [req]
        else
          super
        end
      end
    end
  end
end