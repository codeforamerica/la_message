class AddOptedInToContact < ActiveRecord::Migration[5.2]
  def change
    add_column :contacts, :opted_in, :boolean
  end
end
