class Location < ApplicationRecord
  belongs_to :user, required: false

  has_many :bins
  has_many :skus, through: :bins

end
