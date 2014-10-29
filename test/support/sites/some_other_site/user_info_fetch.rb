module Sites
  module SomeOtherSite
    class UserInfoFetch < Fetch::Module
      def fetch
        fetchable.update_attribute :some_other_id, 1234
      end
    end
  end
end