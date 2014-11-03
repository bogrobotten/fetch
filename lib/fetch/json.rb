module Fetch
  module JSON
    def self.included(base)
      base.defaults do |req|
        req.parse { |body| ::JSON.parse(body) }
      end
    end
  end
end