class User < ApplicationRecord
  has_many :boards, dependent: :destroy

  validates :name, presence: true
  validates :email, presence: true, uniqueness: true
  validates :uid, presence: true, uniqueness: true
  validates :photo_url, presence: false # Allow null for users without photos
end