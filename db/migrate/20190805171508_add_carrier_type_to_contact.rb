class AddCarrierTypeToContact < ActiveRecord::Migration[5.2]
  def change
    add_column :contacts, :carrier_type, :text
  end
end
