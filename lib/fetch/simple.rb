module Fetch
  module Simple
    def self.included(base)
      base.define_callback :url,
                           :timeout,
                           :user_agent,
                           :headers,
                           :process

      base.request do |req|
        req.url        = url
        req.timeout    = timeout if callback?(:timeout)
        req.user_agent = user_agent if callback?(:user_agent)
        req.headers.merge!(headers) if callback?(:headers)
        req.process do |body, url, final_url|
          process(body, url, final_url)
        end
      end
    end
  end
end