module Fetch
  module Async
    module Advanced
      def self.included(base)
        base.extend ClassMethods
      end

      # Returns +true+ if any requests were defined.
      def async?
        super || self.class.requests.any?
      end

      # Requests to be made.
      def requests
        super + self.class.requests.map do |block|
          req = Request.new
          instance_exec req, &block
          req
        end
      end

      module ClassMethods
        # Array of request blocks.
        def requests
          @requests ||= []
        end

        # Defines a new request block.
        #
        #   request do |req|
        #     req.url = "http://www.google.com"
        #     req.method = :post
        #   end
        def request(&block)
          requests << block
        end
      end
    end
  end
end