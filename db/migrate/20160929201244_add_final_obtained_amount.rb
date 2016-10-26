class AddFinalObtainedAmount < ActiveRecord::Migration[5.0]
  def change
    add_column :transactions, :final_obtained_amount, :float
  end
end
