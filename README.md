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

In this example we will use Fetch to fetch user ids from various sites based
on a user's login.

### Fetchable

In *app/models/user.rb*:

```ruby
class User < ActiveRecord::Base
  include Fetchable
  # When you do nothing more, it will fetch using UserFetcher
end
```

### Fetcher

In *lib/user_fetcher.rb*:

```ruby
class UserFetcher < Fetch::Base
  namespace :sites

  sources do
    [:facebook, :github]
  end

  modules do
    :user_info_fetch
  end
end
```

### Fetch modules

In *lib/sites/facebook/user_info_fetch.rb*:

```ruby
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
```

In *lib/sites/github/user_info_fetch.rb*:

```ruby
module Sites
  module Github
    class UserInfoFetch < Fetch::Module
      include Async

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
```

### Doing the fetch

After everything is set up, you can activate the fetch:

```ruby
user = User.find(123)
user.fetcher.fetch
```

This will do an asynchronous (parallel) fetch from the sites, Facebook and GitHub.

## Contributing

Contributions are much appreciated. To contribute:

1. Fork the project
2. Create a feature branch (`git checkout -b my-new-feature`)
3. Make your changes, including tests so it doesn't break in the future
4. Commit your changes (`git commit -am 'Add feature'`)
5. Push to the branch (`git push origin my-new-feature`)
6. Create new pull request

Please do not touch the version, as this will be updated by the owners when the gem is ready for a new release.