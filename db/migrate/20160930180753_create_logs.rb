class CreateLogs < ActiveRecord::Migration[5.0]
  def change
    create_table :logs do |t|
      t.integer :money_burst_id
      t.text :data, limit: 1000000

      t.timestamps
    end

    add_index :logs, :money_burst_id
  end
end
