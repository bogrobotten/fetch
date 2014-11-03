[![Build Status](https://secure.travis-ci.org/bogrobotten/fetch.png)](http://travis-ci.org/bogrobotten/fetch)

# Fetch

![Fetch](http://i.imgur.com/B8TXlri.png)

Fetch enables easy fetching of data from multiple web sources.
It was extracted from [Bogrobotten](http://www.bogrobotten.dk) where we use it
to fetch prices and other stuff from multiple merchants.
We use it for price comparison, but you can use it for anything that involves
fetching data from external sources.

Fetch uses the [Typhoeus](https://github.com/typhoeus/typhoeus) gem for fast
and reliable asynchronous fetches from multiple URLs.

## Installation

Add this line to your application's *Gemfile*:

```ruby
gem "fetch"
```

Then run:

```bash
$ bundle
```

## Example

In *app/models/user.rb*:

```ruby
class User < ActiveRecord::Base
  def fetcher
    @fetcher ||= UserFetcher.new(self)
  end
end
```

In *app/fetchers/user_fetcher.rb*:

```ruby
class UserFetcher < Fetch::Base
  modules Facebook::UserInfoFetch,
          Github::UserInfoFetch
end
```

In *lib/facebook/user_info_fetch.rb*:

```ruby
module Facebook
  class UserInfoFetch < Fetch::Module
    include Fetch::Simple

    url do
      "http://graph.facebook.com/#{fetchable.login}"
    end

    process do |body|
      user_info = JSON.parse(body)
      fetchable.update_attribute :facebook_id, user_info["id"]
    end
  end
end
```

In *lib/github/user_info_fetch.rb*

```ruby
module Github
  class UserInfoFetch < Fetch::Module
    # Request for user ID
    request do |req|
      req.url = "https://api.github.com/users/#{fetchable.login}"
      req.process do |body|
        user_info = JSON.parse(body)
        fetchable.update_attribute :github_id, user_info["id"]
      end
    end

    # Request for repos
    request do |req|
      req.url = "https://api.github.com/users/#{fetchable.login}/repos"
      req.process do |body|
        repos = JSON.parse(body)
        repo_names = repos.map { |r| r["name"] }
        fetchable.update_attribute :github_repos, repo_names
      end
    end
  end
end
```

Then, when everything is set up, you can do:

```ruby
user = User.find(123)
user.fetcher.fetch
```

This will run three requests – one for Facebook and two for GitHub – and update
the user model with a Facebook user ID, a GitHub user ID, and a list of GitHub
repos.

## Contributing

Contributions are much appreciated. To contribute:

1. Fork the project
2. Create a feature branch (`git checkout -b my-new-feature`)
3. Make your changes, including tests so it doesn't break in the future
4. Commit your changes (`git commit -am 'Add feature'`)
5. Push to the branch (`git push origin my-new-feature`)
6. Create new pull request

Please do not touch the version, as this will be updated by the owners when the gem is ready for a new release.