module Sites
  module Facebook
    class UserInfoFetch < Fetch::Module
      include Async

      def url
        "http://graph.facebook.com/#{fetchable.login}"
      end

      def response
        json = JSON.parse(body)

        fetchable.update_attribute :facebook_id, json["id"]
      end
    end
  end
end