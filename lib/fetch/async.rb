require "fetch/async/simple"
require "fetch/async/advanced"

module Fetch
  module Async
    def self.included(base)
      base.define_callback :before_first_process,
                           :before_process
      base.send :include, Simple
      base.send :include, Advanced
    end

    # Whether this is an async request.
    def async?
      false
    end

    # Requests to be made.
    def requests
      []
    end

    # Async requests to be enqueued with +Typhoeus::Hydra+.
    def typhoeus_requests(&callback)
      remaining_requests = requests.count
      before_first_process_called = false

      requests.map do |req|
        request = Typhoeus::Request.new(
          req.url,
          method: req.method,
          body: req.body_string,
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