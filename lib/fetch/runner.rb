module Fetch
  class Runner
    def initialize(*builders)
      @builders = builders.flatten.map do |builder|
        builder = builder.new if builder.is_a?(Class)
        builder
      end
    end

    def run(&callback)
      requests = builders.map(&:requests).flatten
      callback = Proc.new {} unless callback
      backend.new(requests).run(&callback)
    end

    private

    attr_reader :builders

    def backend
      Fetch.config.backend
    end
  end
end