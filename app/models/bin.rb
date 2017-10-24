class Bin < ApplicationRecord

  belongs_to :location, required: false
  belongs_to :sku, required: false

  validates :qty, numericality: {greater_than_or_equal_to: 0, message:
    "Attempt to take quantity below zero" }

end
