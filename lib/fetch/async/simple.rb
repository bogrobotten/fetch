module Fetch
  module Async
    module Simple
      def self.included(base)
        base.define_callback :url,
                             :timeout,
                             :user_agent,
                             :headers,
                             :process
      end

      # Returns +true+ if a URL has been defined using `url do ... end`.
      def async?
        super || callback?(:url)
      end

      # Requests to be made.
      def requests
        super + Array(url).map do |url|
          req = Request.new(url)
          req.timeout    = timeout if callback?(:timeout)
          req.user_agent = user_agent if callback?(:user_agent)
          req.headers.merge!(headers) if callback?(:headers)
          req.process do |body, url, final_url|
            process(body, url, final_url)
          end
          req
        end
      end
    end
  end
end