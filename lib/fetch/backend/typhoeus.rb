module Fetch
  module Backend
    class Typhoeus < Base
      def run(&progress)
        hydra = ::Typhoeus::Hydra.new

        build_requests(&progress).each do |request|
          hydra.queue(request)
        end

        hydra.run
      end

      private

      def build_requests(&progress)
        requests.map do |req|
          request = ::Typhoeus::Request.new(
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
              req.process!(res.body, req.url, res.effective_url)
            else
              raise HttpError.new(res.return_message)
            end
            progress.call
          end

          request
        end
      end
    end
  end
end