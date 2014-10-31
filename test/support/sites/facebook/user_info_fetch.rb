module Sites
  module Facebook
    class UserInfoFetch < Fetch::Module
      request do |req|
        req.url = "http://graph.facebook.com/#{fetchable.login}"
        req.process do |body|
          json = JSON.parse(body)
          fetchable.update_attribute :facebook_id, json["id"]
        end
      end
    end
  end
end