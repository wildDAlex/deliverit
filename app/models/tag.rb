class Tag < ActiveRecord::Base
  has_many :taggings
  has_many :shares, through: :taggings
  belongs_to :user

  scope :owned_by, ->(user) { where(user_id: user.id) }
end
