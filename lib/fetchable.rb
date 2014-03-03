module Fetchable
  extend ActiveSupport::Concern

  included do
    fetchable_with "#{name}Fetch"
  end

  module ClassMethods
    def fetchable_with(class_name)
      has_one :fetch, class_name: class_name, as: :fetchable
    end
  end
end