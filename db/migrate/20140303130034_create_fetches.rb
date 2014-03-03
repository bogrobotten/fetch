class CreateFetches < ActiveRecord::Migration
  def change
    create_table :fetches do |t|
      t.string :type
      t.integer :fetchable_id
      t.string :fetchable_type
      t.string :uuid
      t.datetime :started_at
      t.datetime :completed_at
      t.integer :completed_count
      t.integer :remaining_count

      t.timestamps
    end

    add_index :fetches, [:fetchable_type, :fetchable_id]
    add_index :fetches, :uuid, unique: true
  end
end
