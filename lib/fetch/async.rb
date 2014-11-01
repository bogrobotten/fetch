module Fetch
  module Async
    def self.included(base)
      base.define_callback :request
    end

    def requests
      self.class.callbacks[:request].map do |callback|
        Request.new.tap do |req|
          req.failure { |code| failure(code) } if callback?(:failure)
          req.error { |e| error(e) } if callback?(:error)
          instance_exec(req, &callback)
        end
      end
    end
  end
end