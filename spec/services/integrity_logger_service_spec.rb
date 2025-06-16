require 'rails_helper'

RSpec.describe IntegrityLoggerService, type: :service do

  describe '.log' do
    let(:attributes) do
      {
        idfa: '8264148c-be95-4b2b-b260-6ee98dd53P45',
        ban_status: 'banned',
        ip: '192.168.1.1',
        rooted_device: false,
        country: 'US',
        proxy: true,
        vpn: true
      }
    end

    it 'creates a new IntegrityLog record with valid attributes' do

      expect { described_class.log(attributes) }.to change { IntegrityLog.count }.by(1)
    end

    it 'raises an error if required attributes are missing' do

      attributes.delete(:idfa)
      expect { described_class.log(attributes) }.to raise_error(ActiveRecord::RecordInvalid)
    end

    it 'logs the correct details to the database' do

      described_class.log(attributes)
      log = IntegrityLog.last

      expect(log.idfa).to eq('8264148c-be95-4b2b-b260-6ee98dd53P45')
      expect(log.ban_status).to eq('banned')
      expect(log.ip).to eq('192.168.1.1')
      expect(log.rooted_device).to eq(false)
      expect(log.country).to eq('US')
      expect(log.proxy).to eq(true)
      expect(log.vpn).to eq(true)
    end
  end
end
