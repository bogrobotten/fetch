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

          request.on_success do |res|
            req.process!(res.body, req.url, res.effective_url)
            progress.call
          end

          request.on_failure do |res|
            begin
              raise HttpError.new(res.code, req.url)
            rescue => e
              req.failed!(e)
            end
            progress.call
          end

          request
        end
      end
    end
  end
end