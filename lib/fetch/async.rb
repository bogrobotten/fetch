module Fetch
  module Async
    def self.included(base)
      base.define_callback :url, :response
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

    # Returns +true+.
    def async?
      true
    end

    # Async requests to be enqueued with +Typhoeus::Hydra+.
    def request(&callback)
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
              effective_url = res.effective_url || url
              response(res.body, url, effective_url)
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