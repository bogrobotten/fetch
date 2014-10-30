class UserFetcher < Fetch::Base
  sources do
    [:facebook, :github, :some_other_site]
  end
  
  modules do
    :user_info_fetch
  end

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