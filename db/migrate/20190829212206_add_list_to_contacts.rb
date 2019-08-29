class AddListToContacts < ActiveRecord::Migration[5.2]
  def change
    add_column :contacts, :list, :text
  end
end
