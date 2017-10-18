class Location < ApplicationRecord
  belongs_to :user, required: false

  has_many :bins
  has_many :skus, through: :bins

  # Bring in shared scopes from the concerns file
  include AllActive
  
end
