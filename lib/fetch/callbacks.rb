module Fetch
  module Callbacks
    def self.included(base)
      base.extend ClassMethods
    end

    private

    # Run specific callbacks.
    #
    #   run_callbacks_for(:before_fetch)
    #   run_callbacks_for(:progress, 12) # 12 percent done
    def run_callbacks_for(callback, *args)
      results = []
      self.class.callbacks[callback].each do |block|
        results << instance_exec(*args, &block)
      end
      results.last
    end

    module ClassMethods
      # Hash of callback blocks to be called.
      def callbacks
        @callbacks ||= Hash.new { |h, k| h[k] = [] }
      end

      # Defines callback methods on the class level.
      def define_callback(*names)
        names.each do |name|
          define_singleton_method name do |&block|
            callbacks[name] << block
          end

          define_method name do |*args|
            run_callbacks_for(name, *args)
          end
        end
      end
    end
  end
end