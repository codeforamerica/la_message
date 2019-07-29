class Contact < ApplicationRecord
  has_many :messages, -> { order(created_at: :asc) }
end
