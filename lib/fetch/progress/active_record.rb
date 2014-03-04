module Fetch
  module Progress
    module ActiveRecord
      class Progress < ActiveRecord::Base
        self.table_name = "fetch_progresses"
      end
    end
  end
end