class CreateGeneralInfos < ActiveRecord::Migration[5.0]
  def change
    create_table :general_infos do |t|
      t.text :data, limit: 1000000

      t.timestamps
    end
  end
end
