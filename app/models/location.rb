class Location < ApplicationRecord
  belongs_to :user, required: false

  has_many :bins
  has_many :skus, through: :bins


  validates :name, presence: true
  validates :name, uniqueness: true

  # Bring in shared scopes from the concerns file
  include AllActive
  include AdminValidator

  validates_with AdminValidator

end
