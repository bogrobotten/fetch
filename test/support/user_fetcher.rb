class UserFetcher < Fetch::Base
  modules Sites::Github::UserInfoFetch,
          Sites::Facebook::UserInfoFetch,
          Sites::SomeOtherSite::UserInfoFetch

  before_fetch do
    puts "before fetch"
  end

  after_fetch do
    puts "after fetch"
  end

  progress do |progress|
    puts progress
  end
end