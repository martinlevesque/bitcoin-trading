class CreateTransactions < ActiveRecord::Migration[5.0]
  def change
    create_table :transactions do |t|
      t.integer :money_burst_id
      t.string :trans_type
      t.float :amount
      t.float :price

      t.timestamps
    end

    add_index :transactions, :money_burst_id
  end
end
