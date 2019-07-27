class CreateContacts < ActiveRecord::Migration[5.2]
  def change
    create_table :contacts do |t|
      t.timestamps

      t.text :name
      t.text :phone_number
    end
  end
end
