class AddStatusAndErrorsToMessages < ActiveRecord::Migration[5.2]
  def change
    add_column :messages, :status, :text
    add_column :messages, :error_code, :integer
    add_column :messages, :error_message, :text
  end
end
