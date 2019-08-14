class RenameEnrollmentDocumentsAndRemoveDocumentsDueFromContacts < ActiveRecord::Migration[5.2]
  def change
    rename_column :contacts, :documents, :enrollment_documents
    remove_column :contacts, :documents_due_date
  end
end
