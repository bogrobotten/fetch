module Fetch
  module Async
    # URL or array of URLs to call in the request.
    # Must be implemented to do async fetch.
    #
    #   def url
    #     "https://api.github.com/users/#{fetchable.login}"
    #   end
    def url
      raise "#{self.class.name} must implement #url to do async fetch."
    end

    # Method that implements the logic for handling the response retrieved from
    # +#url+.
    # Must be implemented to do async fetch.
    #
    #   def response
    #     json = JSON.parse(body)
    #     # do something with the JSON
    #   end
    def response
      raise "#{self.class.name} must implement #response that handles response to do async fetch."
    end

    # Returns the current URL being processed; useful when fetching from
    # multiple URLs.
    attr_reader :current_url

    # Returns the final URL in the request, e.g. after being redirected.
    attr_reader :effective_url

    # Returns the body of the response retrieved from the URL.
    # To be used in +#response+.
    attr_reader :body

    # Returns +true+.
    def async?
      true
    end

    # Async requests to be enqueued with +Typhoeus::Hydra+.
    def requests(&callback)
      urls = Array(url)

      remaining_requests = urls.count

      urls.map do |url|
        request = Typhoeus::Request.new(
          url,
          followlocation: true,
          timeout: Fetch.config.timeout,
          forbid_reuse: true,
          headers: { "User-Agent" => Fetch.config.user_agent }
        )

        request.on_complete do |res|
          if res.success?
            begin
              @current_url = url
              @effective_url = res.effective_url || url
              @body = res.body
              response
            rescue => e
              failed e
            end
          else
            failed r.return_message
          end

          remaining_requests -= 1

          if remaining_requests == 0 && callback
            callback.call
          end
        end

        request
      end
    end
  end
end