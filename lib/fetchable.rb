module Fetchable
  extend ActiveSupport::Concern

  def fetch
    @fetch ||= self.class.fetcher.new(self)
  end

  module ClassMethods
    def fetchable_with(class_name)
      @fetcher = class_name
    end

    def fetcher
      @fetcher ||= "#{self.class.name}Fetch"
      @fetcher = @fetcher.constantize if @fetcher.is_a?(String)
      @fetcher
    end
  end
end