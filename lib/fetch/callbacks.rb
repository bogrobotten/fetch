module Fetch
  module Callbacks
    def self.included(base)
      base.extend ClassMethods
    end

    # Run specific callbacks.
    #
    #   run_callbacks_for(:before_fetch)
    #   run_callbacks_for(:progress, 12) # 12 percent done
    def run_callbacks_for(callback, *args)
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