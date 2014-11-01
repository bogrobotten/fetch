module Fetch
  module Backend
    class Base
      attr_reader :requests

      def initialize(requests)
        @requests = requests
      end

      def run(&progress)
        raise NotImplementedError
      end
    end
  end
end