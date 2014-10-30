module Sites
  module Github
    class UserInfoFetch < Fetch::Module
      include Async

      url do
        "https://api.github.com/users/#{fetchable.login}"
      end

      response do |body|
        json = JSON.parse(body)
        
        fetchable.update_attribute :github_id, json["id"]
      end
    end
  end
end