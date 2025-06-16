class IntegrityLog < ApplicationRecord  
  validates :idfa, presence: true
  validates :ban_status, inclusion: { in: %w[banned not_banned] }
end