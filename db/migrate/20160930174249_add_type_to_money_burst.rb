class AddTypeToMoneyBurst < ActiveRecord::Migration[5.0]
  def change
    add_column :money_bursts, :type, :string, default: "TradingBurst"
    add_index :money_bursts, :type
  end
end
