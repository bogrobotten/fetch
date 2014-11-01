module Fetch
  module Async
    def self.included(base)
      base.define_callback :request
    end

    def requests
      self.class.callbacks[:request].map do |callback|
        req = Request.new
        instance_exec(req, &callback)
        req
      end
    end
  end
end