module Sites
  module Github
    class UserInfoFetch < Fetch::Module
      include Async

      def url
        "https://api.github.com/users/#{fetchable.login}"
      end

      def response
        json = JSON.parse(body)
        
        fetchable.update_attribute :github_id, json["id"]
      end
    end
  end
end