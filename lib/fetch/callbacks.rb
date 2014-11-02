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
      self.class.callbacks[name].map do |block|
        instance_exec(*args, &block)
      end
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
            add_callback(name, &block)
          end

          define_method name do |*args|
            run_callbacks_for(name, *args).last
          end
        end
      end

      def inherited(base)
        super
        callbacks.each do |name, callbacks|
          base.callbacks[name] = callbacks.dup
        end
      end

      private

      def add_callback(name, &block)
        callbacks[name] << block
      end
    end
  end
end