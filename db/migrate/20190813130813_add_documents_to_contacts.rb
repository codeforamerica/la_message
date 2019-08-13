class AddDocumentsToContacts < ActiveRecord::Migration[5.2]
  def change
    add_column :contacts, :documents, :text, array: true, default: []
    add_column :contacts, :documents_due_date, :date
  end
end
