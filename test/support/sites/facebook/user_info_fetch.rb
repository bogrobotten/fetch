module Sites
  module Facebook
    class UserInfoFetch < Fetch::Module
      include Async

      url do
        "http://graph.facebook.com/#{fetchable.login}"
      end

      process do |body|
        json = JSON.parse(body)

        fetchable.update_attribute :facebook_id, json["id"]
      end
    end
  end
end