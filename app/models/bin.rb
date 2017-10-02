class Bin < ApplicationRecord

  belongs_to :location, required: false
  belongs_to :sku, required: false

end
