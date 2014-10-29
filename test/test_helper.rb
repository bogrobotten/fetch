require "minitest/autorun"
require "active_record"

require "fetch"

# Load support files
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

# Set up database
ActiveRecord::Base.establish_connection adapter: "sqlite3", database: ":memory:"

ActiveRecord::Migration.create_table :users do |t|
  t.string :login
  t.integer :github_id
  t.integer :twitter_id
  t.integer :some_other_id
end

# Load fixtures
Dir["#{File.dirname(__FILE__)}/fixtures/**/*.rb"].each { |f| require f }

# Configure Fetch
Fetch.configure do |config|
  config.raise_on_error = true
end