class UserFetch < Fetch::Base
  fetches_from [:github, :some_other_site]
  fetches_with :user_info_fetch

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