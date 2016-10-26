class AddDiffAfterBuying < ActiveRecord::Migration[5.0]
  def change
    add_column :money_bursts, :remaining_after_buying, :float, default: 0.0
  end
end
