class AddOptInsToPhoneNumber < ActiveRecord::Migration[5.2]
  def change
    add_column :phone_numbers, :wic_opt_in, :boolean, default: false
    add_column :phone_numbers, :medicaid_opt_in, :boolean, default: false
    add_column :phone_numbers, :snap_opt_in, :boolean, default: false
    add_column :phone_numbers, :tanf_opt_in, :boolean, default: false
  end
end
