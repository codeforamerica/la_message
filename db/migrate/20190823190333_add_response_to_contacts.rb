class AddResponseToContacts < ActiveRecord::Migration[5.2]
  def change
    add_column :contacts, :response, :text
  end
end
