class CreateMoneyBursts < ActiveRecord::Migration[5.0]
  def change
    create_table :money_bursts do |t|
      t.float :init_amount
      t.float :cur_amount
      t.string :cur_currency
      t.text :data

      t.timestamps
    end
  end
end
