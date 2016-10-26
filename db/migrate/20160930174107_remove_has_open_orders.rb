class RemoveHasOpenOrders < ActiveRecord::Migration[5.0]
  def change
    remove_column :money_bursts, :has_open_orders
  end
end
