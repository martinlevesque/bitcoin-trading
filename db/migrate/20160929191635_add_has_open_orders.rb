class AddHasOpenOrders < ActiveRecord::Migration[5.0]
  def change
    add_column :money_bursts, :has_open_orders, :boolean, default: false
    add_index :money_bursts, :has_open_orders
  end
end
