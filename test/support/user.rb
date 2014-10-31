class User < ActiveRecord::Base
  include Fetchable

  serialize :github_repos, Array
end