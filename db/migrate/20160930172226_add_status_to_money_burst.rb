class AddStatusToMoneyBurst < ActiveRecord::Migration[5.0]
  def change
    add_column :money_bursts, :state, :string, default: :idle
    add_index :money_bursts, :state
  end
end
