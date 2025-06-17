require 'rails_helper'

RSpec.describe IntegrityLog, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:idfa) }
    it { should validate_presence_of(:ban_status) }
  end

  describe 'enums' do
    
    it 'has the correct enum values for ban_status' do
      expect(described_class.ban_statuses.keys).to contain_exactly('not_banned', 'banned')
    end
  end
end
