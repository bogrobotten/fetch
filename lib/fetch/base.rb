module Fetch
  class Base < ActiveRecord::Base
    self.table_name = "fetches"
    before_validation :set_uuid

    # Fetch modules definition
    class << self
      def fetch_modules
        @fetch_modules ||= []
      end

      attr_writer :fetch_modules

      def fetches_with(*module_keys)
        self.fetch_modules |= module_keys.map { |key| key.to_s.camelize }
      end
    end
    
    # Callbacks
    class << self
      def callbacks
        @callbacks ||= Hash.new { |h, k| h[k] = [] }
      end

      [:before_fetch, :after_fetch].each do |callback|
        define_method callback do |&block|
          callbacks[callback] << block
        end
      end

      def run_callbacks_for(callback)
        callbacks[callback].each { |block| block.call }
      end
    end


    # Fetch
    def begin
    end

    private

      def set_uuid
        return if uuid?

        begin
          self.uuid = SecureRandom.hex(5)
        end while FetchQueue.exists?(uuid: uuid)
      end
  end
end