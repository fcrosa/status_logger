class User < ApplicationRecord
  validates :idfa, presence: true, uniqueness: true
  validates :ban_status, inclusion: { in: %w[banned not_banned] }

  def banned?
    ban_status == 'banned'
  end

  def not_banned?
    ban_status == 'not_banned'
  end
end