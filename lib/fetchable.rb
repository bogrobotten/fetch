# Module to be included in objects that can be fetched, e.g. a User, Product, etc.
module Fetchable
  def self.included(base)
    base.extend ClassMethods
  end

  # Returns an instance of the fetch handler defined with +fetches_with+.
  # If +fetches_with+ isn't set manually, it will derive the fetch module
  # from its name, e.g. a `Product` uses `ProductFetch`.
  #
  #   class Product < ActiveRecord::Base
  #     include Fetchable
  #     fetches_with "MyFetch"
  #   end
  #
  #   Product.find(2).fetch # => instance of MyFetch
  def fetcher
    @fetcher ||= self.class.fetcher.new(self)
  end

  module ClassMethods
    # Defines which fetch handler to use when fetching instances of this class.
    # Can be a class or string, which will be instantiated and returned from
    # +#fetch+.
    def fetches_with(class_name)
      @fetcher = class_name
    end

    # Returns the fetch handler class set with +fetches_with+.
    # Default is derived from the name of the class, e.g.:
    #
    #   class Product < ActiveRecord::Base
    #   end
    #   
    #   Product.fetcher # => ProductFetch
    def fetcher
      @fetcher ||= "#{name}Fetcher"
      @fetcher = @fetcher.constantize if @fetcher.is_a?(String)
      @fetcher
    end
  end
end