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
    def run_callbacks_for(name, args, reverse)
      callbacks_for(name, reverse).map do |block|
        run_callback(block, args)
      end
    end

    def run_last_callback_for(name, args, reverse)
      if block = callbacks_for(name, reverse).last
        run_callback(block, args)
      end
    end

    def callbacks_for(name, reverse)
      callbacks = self.class.callbacks[name]
      callbacks = callbacks.reverse if reverse
      callbacks
    end

    def run_callback(block, args)
      instance_exec(*args, &block)
    end

    module ClassMethods
      # Hash of callback blocks to be called.
      def callbacks
        @callbacks ||= Hash.new { |h, k| h[k] = [] }
      end

      # Defines callback methods on the class level.
      def define_callback(*names)
        options = names.last.is_a?(Hash) ? names.pop : {}
        reverse = !!options[:reverse]

        names.each do |name|
          define_singleton_method name do |*values, &block|
            create_callback_for(name, values, block)
          end

          define_method name do |*args|
            run_callbacks_for(name, args, reverse).last
          end

          define_method "#{name}!" do |*args|
            run_last_callback_for(name, args, reverse)
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

      def create_callback_for(name, values, block)
        add_callback(name, ->{ values }) if values.any?
        add_callback(name, block) if block
      end

      def add_callback(name, block)
        callbacks[name] << block
      end
    end
  end
end