module Sites
  module Github
    class UserInfoFetch < Fetch::Module
      request do |req|
        req.url = "https://api.github.com/users/#{fetchable.login}"
        req.process do |body|
          json = JSON.parse(body)
          fetchable.update_attribute :github_id, json["id"]
        end
      end

      request do |req|
        req.url = "https://api.github.com/users/#{fetchable.login}/repos"
        req.process do |body|
          json = JSON.parse(body)
          fetchable.update_attribute :github_repos, json.map { |r| r["name"] }
        end
      end
    end
  end
end