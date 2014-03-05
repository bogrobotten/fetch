module Fetch
  module Async
    def url
      raise "#{self.class.name} must implement #url to do async fetch."
    end

    def response
      raise "#{self.class.name} must implement #response that handles response to do async fetch."
    end

    attr_reader :current_url
    attr_reader :effective_url
    attr_reader :body

    def async?
      true
    end

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