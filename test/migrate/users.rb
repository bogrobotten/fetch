ActiveRecord::Migration.create_table :users do |t|
  t.string :login
  t.integer :github_id
  t.integer :facebook_id
  t.integer :some_other_id
end