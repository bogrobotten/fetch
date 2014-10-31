module Fetch
  module Async
    def self.included(base)
      base.define_callback :url,
                           :timeout,
                           :user_agent,
                           :headers,
                           :before_first_process,
                           :before_process,
                           :process
    end

    # Returns +true+ if a URL has been defined using `url do ... end`.
    def async?
      callback?(:url)
    end

    # Async requests to be enqueued with +Typhoeus::Hydra+.
    def requests(&callback)
      requests = []

      if callback?(:url)
        url_requests = Array(url).map do |url|
          req = Request.new(url)
          req.timeout    = timeout if callback?(:timeout)
          req.user_agent = user_agent if callback?(:user_agent)
          req.headers.merge!(headers) if callback?(:headers)
          req.process do |body, url, final_url|
            process(body, url, final_url)
          end
          req
        end
        requests.concat url_requests
      end

      remaining_requests = requests.count
      before_first_process_called = false

      requests.map do |req|
        request = Typhoeus::Request.new(
          req.url,
          followlocation: req.follow_redirects,
          timeout: req.timeout,
          forbid_reuse: true,
          headers: req.headers
        )

        request.on_complete do |res|
          if res.success?
            unless before_first_process_called
              before_first_process_called = true
              before_first_process
            end

            before_process(url)

            begin
              effective_url = res.effective_url || req.url
              req.process.call(res.body, req.url, effective_url)
            rescue => e
              failed e
            end
          else
            failed res.return_message
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