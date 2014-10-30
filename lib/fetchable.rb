# When included, marks a class as being fetchable, e.g. a User, Product, etc.
module Fetchable
  def self.included(base)
    base.send :include, Fetch::Callbacks
    base.define_callback :before_fetch, :after_fetch

    base.extend ClassMethods
  end

  # Returns an instance of the fetcher defined with +fetches_with+.
  # If +fetches_with+ isn't set manually, it will derive the fetcher class
  # from the class name, e.g. a `Product` uses `ProductFetcher` by default.
  #
  #   class Product < ActiveRecord::Base
  #     include Fetchable
  #     fetches_with "MyFetcher"
  #   end
  #
  #   Product.find(2).fetcher # => instance of MyFetcher
  def fetcher
    @fetcher ||= self.class.fetcher.new(self)
  end

  # A unique key for this fetchable. By default it is comprised of the class
  # name and id.
  #
  #   class Product < ActiveRecord::Base
  #     include Fetchable
  #   end
  #
  #   Product.find(123).fetch_key
  #   # => "Product123"
  def fetch_key
    "#{self.class.name}#{id}"
  end

  module ClassMethods
    # Defines which fetcher to use when fetching instances of this class.
    # Can be a class or string, which will be instantiated and returned from
    # +#fetcher+.
    def fetches_with(class_name)
      @fetcher = class_name
    end

    # Returns the fetcher class set with +fetches_with+.
    # If no fetcher class has been set, it will derive it from the class name,
    # e.g.:
    #
    #   class Product < ActiveRecord::Base
    #   end
    #   
    #   Product.fetcher # => ProductFetcher
    def fetcher
      @fetcher ||= "#{name}Fetcher"
      @fetcher = @fetcher.constantize if @fetcher.is_a?(String)
      @fetcher
    end
  end
end