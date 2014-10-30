module Fetch
  module Callbacks
    def self.included(base)
      base.extend ClassMethods
    end

    private

    # Check if a callback has been used.
    def callback?(name)
      self.class.callbacks[name].any?
    end

    # Run specific callbacks.
    #
    #   run_callbacks_for(:before_fetch)
    #   run_callbacks_for(:progress, 12) # 12 percent done
    def run_callbacks_for(name, *args)
      results = []
      self.class.callbacks[name].each do |block|
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

      def inherited(base)
        base.instance_variable_set(:@callbacks, @callbacks.dup) unless @callbacks.nil?
      end
    end
  end
end