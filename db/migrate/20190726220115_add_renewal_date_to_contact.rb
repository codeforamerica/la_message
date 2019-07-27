class AddRenewalDateToContact < ActiveRecord::Migration[5.2]
  def change
    add_column :contacts, :renewal_date, :date
  end
end
