class CreateGenInfo < ActiveRecord::Migration[5.0]
  def change
    GeneralInfo.create
  end
end
