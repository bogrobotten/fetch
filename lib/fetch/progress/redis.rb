module Fetch
  module Progress
    module Redis
      def self.included(base)
        base.before_fetch do
          progress.before_fetch
        end

        base.progress do |progress|
          progress.progress(progress) # Yes, I spelled progress three times ;-)
        end

        base.after_fetch do
          progress.after_fetch
        end
      end

      def progress(*args)
        if args.any?
          super
        else
          @progress ||= Progress.new(fetch_key)
        end
      end

      class Progress
        attr_reader :fetch_key

        def initialize(fetch_key)
          @fetch_key = fetch_key
        end

        def before_fetch
          redis.pipelined do
            redis.set("#{redis_prefix}:started_at", Time.now)
            redis.set("#{redis_prefix}:progress", 0)
            redis.del("#{redis_prefix}:completed_at")
          end
        end

        def progress(progress)
          redis.set("#{redis_prefix}:progress", progress)
        end

        def after_fetch
          redis.pipelined do
            redis.set("#{redis_prefix}:progress", 100)
            redis.set("#{redis_prefix}:completed_at", Time.now)
          end
        end

        private

        def redis
          Fetch.config.redis
        end

        def redis_prefix
          "fetch:progress:#{fetch_key}"
        end
      end
    end
  end
end