class AddSegmentToContacts < ActiveRecord::Migration[5.2]
  def change
    add_column :contacts, :segment, :int
  end
end
