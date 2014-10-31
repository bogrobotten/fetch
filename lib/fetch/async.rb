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
      urls = Array(url)

      remaining_requests = urls.count
      before_first_process_called = false

      urls.map do |url|
        request = Typhoeus::Request.new(
          url,
          followlocation: true,
          timeout: (timeout || Fetch.config.timeout),
          forbid_reuse: true,
          headers: { "User-Agent" => (user_agent || Fetch.config.user_agent) }.merge(headers || {})
        )

        request.on_complete do |res|
          if res.success?
            unless before_first_process_called
              before_first_process_called = true
              before_first_process
            end

            before_process(url)

            begin
              effective_url = res.effective_url || url
              process(res.body, url, effective_url)
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