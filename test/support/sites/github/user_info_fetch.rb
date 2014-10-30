module Sites
  module Github
    class UserInfoFetch < Fetch::Module
      url do
        "https://api.github.com/users/#{fetchable.login}"
      end

      process do |body|
        json = JSON.parse(body)
        
        fetchable.update_attribute :github_id, json["id"]
      end
    end
  end
end