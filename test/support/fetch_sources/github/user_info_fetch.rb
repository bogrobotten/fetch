module FetchSources
  module Github
    class UserInfoFetch < Fetch::Module
      include Fetch::Async

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