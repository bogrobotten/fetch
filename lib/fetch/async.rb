module Fetch
  module Async
    def self.included(base)
      base.define_callback :url,
                           :user_agent,
                           :before_first_process,
                           :process
    end

    # Returns +true+.
    def async?
      true
    end

    # Async requests to be enqueued with +Typhoeus::Hydra+.
    def request(&callback)
      urls = Array(url)

      remaining_requests = urls.count
      before_first_process_called = false

      urls.map do |url|
        request = Typhoeus::Request.new(
          url,
          followlocation: true,
          timeout: Fetch.config.timeout,
          forbid_reuse: true,
          headers: { "User-Agent" => (user_agent || Fetch.config.user_agent) }
        )

        request.on_complete do |res|
          if res.success?
            unless before_first_process_called
              before_first_process_called = true
              before_first_process
            end

            begin
              effective_url = res.effective_url || url
              process(res.body, url, effective_url)
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