class AddIndividualIdToContacts < ActiveRecord::Migration[5.2]
  def change
    add_column :contacts, :individual_id, :text
    add_column :contacts, :lameds_opt_in, :boolean
  end
end
