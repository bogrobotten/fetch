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

In *app/models/user.rb*:

```ruby
class User < ActiveRecord::Base
  include Fetchable
  # When you do nothing more, it will fetch using UserFetcher
end
```

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

In *lib/sites/facebook/user_info_fetch.rb*:

```ruby
module Sites
  module Facebook
    class UserInfoFetch < Fetch::Module
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

After everything is set up, you can activate the fetch:

```ruby
user = User.find(123)
user.fetcher.fetch
```

This will do an asynchronous (parallel) fetch from the sites, Facebook and GitHub.

## Fetch modules

Fetch modules are the classes that contains the URLs and code for processing
your calls to external services.

A fetch module should contain either

* `url do ... end` and `process do ... end` for async fetches. This is the
  preferred method as you can do parallel fetches which makes your fetches run
  faster.

or

* `fetch do ... end` for non-async fetches.

### Async fetch modules

An async fetch module contains at least two blocks: `url do ... end` and
`process do ... end`. The `url` block should return one or more URLs to be
fetched, and the `process` block contains the processing code for the response
coming from the request of the URL.

An example:

```ruby
class UserInfoFetch < Fetch::Module
  url do
    "https://api.github.com/users/#{fetchable.login}"
  end

  process do |body|
    # Do some processing of the response body.
  end
end
```

You can get more information about the response by adding more arguments to the
`process` block:

```ruby
process do |body, url, effective_url|
  # Do some processing.
end
```

The `url` argument is useful if your `url` block returned more than one URL and
you want to get information on which URL is currently being processed.

The `effective_url` is the last URL redirected to. If no redirects occured,
`effective_url` will be the same as `url`.

### Non-async fetch modules

If you want to define a fetch module that doesn't use asynchronous requests,
you can define it using the `fetch` block:

```ruby
class UserInfoFetch < Fetch::Module
  fetch do
    # Do some non-async fetching.
  end
end
```

### Conditional fetching

You can specify whether the fetch module should be used when fetching, using
the `fetch_if` block:

```ruby
class UserInfoFetch < Fetch::Module
  fetch_if do
    # Specify whether the fetch module should be used
  end
end
```


### Callbacks in fetch modules

Fetch modules have various callbacks that can be used for hooking into the
lifecycle of the fetches. You can define multiple callbacks with the same name.

#### 1. `before_fetch`

The `before_fetch` callback is called right before the fetch is started.

```ruby
class UserInfoFetch < Fetch::Module
  before_fetch do
    # Do something before the fetch
  end
end
```

#### 2. `before_first_process`

The `before_first_process` callback is called right before processing the
response. If you have multiple URLs, this is only called once.

```ruby
class UserInfoFetch < Fetch::Module
  before_first_process do
    # Do something before the first process
  end
end
```

#### 3. `before_process`

The `before_process` callback is similar to `before_first_process`, but is
called before processing each response, if you have multiple URLs.

```ruby
class UserInfoFetch < Fetch::Module
  before_process do |url|
    # Do something before the first process
  end
end
```

#### 4. `after_fetch`

The `after_fetch` callback is called after the fetch is completed.

```ruby
class UserInfoFetch < Fetch::Module
  after_fetch do
    # Do something after the fetch
  end
end
```

## Testing

You can create a mock fetcher for testing single fetch modules.
In *test_helper.rb*:

```ruby
def MockFetcher(source_names, module_names)
  Class.new(Fetch::Base) do
    namespace :your_namespace

    sources do
      source_names
    end

    modules do
      module_names
    end
  end
end
```

You can then call it in your tests:

```ruby
user = User.find(123)
fetcher = MockFetcher(:github, :user_info_fetch)
fetcher.new(user).fetch
```

This will run `UserInfoFetch` for `Github` with any callbacks you have set.

## Contributing

Contributions are much appreciated. To contribute:

1. Fork the project
2. Create a feature branch (`git checkout -b my-new-feature`)
3. Make your changes, including tests so it doesn't break in the future
4. Commit your changes (`git commit -am 'Add feature'`)
5. Push to the branch (`git push origin my-new-feature`)
6. Create new pull request

Please do not touch the version, as this will be updated by the owners when the gem is ready for a new release.