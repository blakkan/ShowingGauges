class Sku < ApplicationRecord
  belongs_to :user, required: false

  has_many :bins
  has_many :locations, through: :bins
end
