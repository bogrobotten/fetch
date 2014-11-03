module Fetch
  module Async
    def self.included(base)
      base.define_callback :request,
                           :defaults,
                           :before_process,
                           :after_process

      base.defaults do |req|
        req.before_process { before_process } if callback?(:before_process)
        req.after_process { after_process } if callback?(:after_process)
        req.failure { |code, url| failure(code, url) } if callback?(:failure)
        req.error { |e| error(e) } if callback?(:error)
      end
    end

    def requests
      self.class.callbacks[:request].map do |callback|
        Request.new.tap do |req|
          defaults(req)
          instance_exec(req, &callback)
        end
      end.select(&:url)
    end
  end
end