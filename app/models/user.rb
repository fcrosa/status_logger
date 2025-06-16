class User < ApplicationRecord

  enum ban_status: { 
    not_banned: 0, 
    banned: 1 
    # Other future statuses
    }, _default: :not_banned

  validates :idfa, presence: true, uniqueness: true
  validates :ban_status, presence: true
end