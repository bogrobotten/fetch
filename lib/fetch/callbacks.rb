module Fetch
  module Callbacks
    def self.included(base)
      base.extend ClassMethods
    end

    # Run specific callbacks.
    #
    #   callback(:before_fetch)
    #   callback(:progress, 12) # 12 percent done
    def callback(callback, *args)
      self.class.callbacks[callback].each do |block|
        block.call(*args)
      end
    end

    module ClassMethods
      # Hash of callback blocks to be called.
      def callbacks
        @callbacks ||= Hash.new { |h, k| h[k] = [] }
      end

      # Defines callback methods on the class level.
      def define_callback(*names)
        names.each do |callback|
          define_singleton_method callback do |&block|
            callbacks[callback] << block
          end
        end
      end
    end
  end
end