class ChangeOptInsToEnums < ActiveRecord::Migration[5.2]
  def change
    remove_column :phone_numbers, :medicaid_opt_in, :boolean
    remove_column :phone_numbers, :wic_opt_in, :boolean
    remove_column :phone_numbers, :snap_opt_in, :boolean
    remove_column :phone_numbers, :tanf_opt_in, :boolean

    add_column :phone_numbers, :medicaid_opt_in, :integer, default: 0
    add_column :phone_numbers, :wic_opt_in, :integer, default: 0
    add_column :phone_numbers, :snap_opt_in, :integer, default: 0
    add_column :phone_numbers, :tanf_opt_in, :integer, default: 0
  end
end
