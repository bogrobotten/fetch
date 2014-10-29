module Sites
  module SomeOtherSite
    class UserInfoFetch < Fetch::Module
      fetch do
        fetchable.update_attribute :some_other_id, 1234
      end
    end
  end
end