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
    include Fetch::JSON

    url do
      "http://graph.facebook.com/#{fetchable.login}"
    end

    process do |user_info|
      fetchable.update_attribute :facebook_id, user_info["id"]
    end
  end
end
```

In *lib/github/user_info_fetch.rb*

```ruby
module Github
  class UserInfoFetch < Fetch::Module
    include Fetch::JSON

    # Request for user ID
    request do |req|
      req.url = "https://api.github.com/users/#{fetchable.login}"
      req.process do |user|
        fetchable.update_attribute :github_id, user["id"]
      end
    end

    # Request for repos
    request do |req|
      req.url = "https://api.github.com/users/#{fetchable.login}/repos"
      req.process do |repos|
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

## Good to know

### Adding defaults to your requests

Each fetch module has a `defaults` callback that you can use to set up defaults
for all requests in that modules.

```ruby
class UserInfoFetch < Fetch::Module
  defaults do |req|
    req.user_agent = "My Awesome Bot!"
  end

  request do |req|
    req.url = "http://test.com"
    req.process do |body|
      # Do some processing
    end
  end
end
```

This will add the user agent `My Awesome Bot!` to all requests in the
`UserInfoFetch` module.

The `defaults` callback is inherited, like all other callbacks, so if you have
a base fetch class that you subclass, the `defaults` callback in the superclass
will be run in all subclasses.

### Handling HTTP failures

HTTP failures can be handled using the `failure` callback. If you want to
handle failures for all requests generally, you can use the module-wide
`failure` callback:

```ruby
class UserInfoFetch < Fetch::Module
  request do |req|
    req.url = "http://test.com/something-failing"
    req.process do |body|
      # Do something if successful.
    end
  end

  failure do |code, url|
    Rails.logger.info "Fetching from #{url} failed: #{code}"
  end
end
```

If you want to handle failures on the specific requests instead:

```ruby
class UserInfoFetch < Fetch::Module
  request do |req|
    req.url = "http://test.com/something-failing"
    req.process do |body|
      # Do something if successful.
    end
    req.failure do |code, url|
      # Handle the failure
    end
  end
end
```

When you handle failures directly on the request, the general `failure`
callback isn't called.

**Note:** If you don't specify a `failure` callback at all, HTTP failures are ignored,
and processing skipped for the failed request.

### Handling errors

Sometimes a URL will return something that potentially makes your processing
code fail. To prevent this from breaking your whole fetch, you can handle
errors using the `error` callback:

```ruby
class UserInfoFetch < Fetch::Module
  request do |req|
    req.url = "http://test.com/something-failing"
    req.process do |body|
      # Do something if successful.
    end
  end

  error do |exception|
    Rails.logger.info "An error occured: #{exception.message}\n" +
                      exception.backtrace.join("\n")
    raise exception if ["development", "test"].include?(Rails.env)
  end
end
```

You can also do it directly on the requests:

```ruby
class UserInfoFetch < Fetch::Module
  request do |req|
    req.url = "http://test.com/something-failing"
    req.process do |body|
      # Do something if successful.
    end
    req.error do |exception|
      # Handle the error
    end
  end
end
```

If you handle errors directly on the requests, the general `error` callback
isn't run.

**Note:** If you don't do any error handling in one of the two ways shown
above, any exceptions that occur when processing will be raised, causing the
whole fetch to fail. So please add error handling :blush:

### Parsing JSON

Fetch has a module for automatically parsing the request body as JSON before
it is sent to the process block.

```ruby
class UserInfoFetch < Fetch::Module
  include Fetch::JSON

  request do |req|
    req.url = "http://api.test.com/user"
    req.process do |json|
      # Do something with the JSON.
    end
  end
end
```

### Dynamically loading fetch modules

You can load fetch modules dynamically using the `load` callback. Normally, the
modules defined with `modules` are instantiated directly. When you use the
`load` callback, this will determine how your modules are loaded.

```ruby
class UserFetcher < Fetch::Base
  modules :user_info_fetch, :status_fetch

  load do |modules|
    namespaces.product(modules).map do |path|
      path.join("/").camelize.safe_constantize
    end.compact
  end

  private

  def namespaces
    [:github, :facebook]
  end
end
```

This will load the modules `Github::UserInfoFetch`, `Github::StatusFetch`,
`Facebook::UserInfoFetch` and `Facebook::StatusFetch`, if they are present.

The `load` callback is only run once, so you can safely inherit it – only the
last one defined will be run.

### Initializing fetch modules

Normally, a fetcher is initialized with an optional `fetchable` that is sent
along to the fetch modules when they are initialized. You can change how this
works with the `init` callback.

Let's say you have a `Search` model with a `SearchFetcher` that gets results
from various search engines. Normally, the `Search` instance would be sent to
the fetch modules as a fetchable. Let's say you just want to send the keyword
to reduce coupling.

In *app/fetchers/search_fetcher.rb*:

```ruby
class SearchFetcher < Fetch::Base
  modules Google::KeywordFetch,
          Bing::KeywordFetch

  init do |klass|
    klass.new(fetchable.keyword)
  end
end
```

In *lib/base/keyword_fetch.rb*:

```ruby
module Base
  class KeywordFetch < Fetch::Module
    attr_reader :keyword

    def initialize(keyword)
      @keyword = keyword
    end
  end
end
```

In *lib/google/keyword_fetch.rb*:

```ruby
module Google
  class KeywordFetch < Base::KeywordFetch
    request do |req|
      req.url = "https://www.google.com/search?q=#{CGI::escape(keyword)}"
      req.process do |body|
        # Do something with the body.
      end
    end
  end
end
```

And *lib/bing/keyword_fetch.rb* something similar to Google.

Then:

```ruby
search = Search.find(123)
SearchFetcher.new(search).fetch
```

Now the keyword will be sent to the fetch modules instead of the fetchable.

## Contributing

Contributions are much appreciated. To contribute:

1. Fork the project
2. Create a feature branch (`git checkout -b my-new-feature`)
3. Make your changes, including tests so it doesn't break in the future
4. Commit your changes (`git commit -am 'Add feature'`)
5. Push to the branch (`git push origin my-new-feature`)
6. Create new pull request

Please do not touch the version, as this will be updated by the owners when the gem is ready for a new release.