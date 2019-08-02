class AddFirstNameAndLastNameToContacts < ActiveRecord::Migration[5.2]
  def change
    add_column :contacts, :first_name, :text
    add_column :contacts, :last_name, :text
    remove_column :contacts, :name
  end
end
