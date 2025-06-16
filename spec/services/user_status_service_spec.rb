require 'rails_helper'

RSpec.describe UserStatusService do
  
  let(:headers) { { 'CF-IPCountry' => 'US' } }
  let(:params) do
    {
      idfa: 'test-idfa-123',
      ip_address: '1.2.3.4',
      rooted_device: false
    }
  end
  let(:current_ban_status) { 'not_banned' }

  subject(:service) { described_class.new(headers, params) }
  let(:user) { instance_double(User, idfa: params[:idfa], ban_status: current_ban_status) }
  let(:redis_key) { "vpnapi:#{params[:ip_address]}" }
  let(:vpnapi422_response) { { 'security' => { 'vpn' => false, 'proxy' => false } } }

  before do
    allow(User).to receive(:find_or_initialize_by).with(idfa: params[:idfa]).and_return(user)
    allow(RedisCountriesWhitelist).to receive(:allowed?).and_return(true)
    allow($redis).to receive(:get).and_return(nil)
    allow($redis).to receive(:setex)
    allow(HTTP).to receive(:get).and_return(double(body: vpnapi422_response.to_json))
    allow(IntegrityLoggerService).to receive(:log)
    allow(user).to receive(:update!)
    allow(Rails.logger).to receive(:info)
    allow(Rails.logger).to receive(:error)
  end

  describe '#validate!' do
    context 'when user is already banned' do
  
      let(:current_ban_status) { 'banned' }

      it 'returns banned immediately and skips checks and updates' do
        expect(service.validate!).to eq(ban_status: 'banned')
        expect(User).to have_received(:find_or_initialize_by).with(idfa: params[:idfa])
        expect(user).not_to have_received(:update!)
      end
    end

    context 'when user is not banned' do
  
      let(:current_ban_status) { 'not_banned' }

      context 'and country is not allowed' do
        before do
          allow(RedisCountriesWhitelist).to receive(:allowed?).with('US').and_return(false)
        end

        it 'updates user to banned' do
          expect(service.validate!).to eq(ban_status: 'banned')
          expect(user).to have_received(:update!).with(ban_status: 1)
        end
      end

      context 'and device is rooted' do
  
        let(:params) { super().merge(rooted_device: true) }

        it 'updates user to banned' do
          expect(service.validate!).to eq(ban_status: 'banned')
          expect(user).to have_received(:update!).with(ban_status: 1)
        end
      end

      context 'and vpn or proxy detected' do
        before do
          allow(RedisCountriesWhitelist).to receive(:allowed?).and_return(true)
          allow(service).to receive(:vpn_or_proxy_detected?).and_return(true)
        end

        it 'updates user to banned' do
          expect(service.validate!).to eq(ban_status: 'banned')
          expect(user).to have_received(:update!).with(ban_status: 1)
        end
      end

      context 'and all checks pass' do
  
        before do
          allow(RedisCountriesWhitelist).to receive(:allowed?).and_return(true)
          allow(service).to receive(:vpn_or_proxy_detected?).and_return(false)
        end

        it 'updates user to not_banned' do
          expect(service.validate!).to eq(ban_status: 'not_banned')
          expect(user).to have_received(:update!).with(ban_status: 'not_banned')
        end
      end
    end
  end

  describe '#vpn_or_proxy_detected?' do
    context 'when cached response exists in Redis' do
  
      let(:cached_vpn_data) { { 'security' => { 'vpn' => true, 'proxy' => false } }.to_json }

      before do
        allow($redis).to receive(:get).with(redis_key).and_return(cached_vpn_data)
      end

      it 'returns true if vpn or proxy detected in cached data' do
        expect(service.send(:vpn_or_proxy_detected?)).to be true
      end
    end

    context 'when no cached response exists' do
  
      let(:vpnapi_response) { { 'security' => { 'vpn' => false, 'proxy' => true } } }
      let(:http_response) { double(body: vpnapi_response.to_json) }

      before do
        allow($redis).to receive(:get).with(redis_key).and_return(nil)
        allow(HTTP).to receive(:get).and_return(http_response)
        allow($redis).to receive(:setex)
      end

      it 'makes HTTP request and caches the response' do
        expect(service.send(:vpn_or_proxy_detected?)).to be true
        expect(HTTP).to have_received(:get).with("https://vpnapi.io/api/#{params[:ip_address]}?key=#{ENV['VPNAPI_KEY']}")
        expect($redis).to have_received(:setex).with(redis_key, 24 * 60 * 60, vpnapi_response.to_json)
      end
    end

    context 'when HTTP request raises error' do
  
      before do
        allow($redis).to receive(:get).with(redis_key).and_return(nil)
        allow(HTTP).to receive(:get).and_raise(StandardError.new('API failure'))
      end

      it 'logs error and returns false' do
  
        expect(Rails.logger).to receive(:error).with(/VPNAPI error: API failure/)
        expect(service.send(:vpn_or_proxy_detected?)).to be false
      end
    end
  end

  describe '#country_allowed?' do
  
    it 'calls RedisCountriesWhitelist.allowed? with the country code' do
      expect(RedisCountriesWhitelist).to receive(:allowed?).with('US')
      service.send(:country_allowed?)
    end
  end

  describe '#rooted_device?' do
  
    it 'returns true if rooted_device param is present' do
      expect(service.send(:rooted_device?)).to be false
      service_with_rooted = described_class.new(headers, params.merge(rooted_device: true))
      expect(service_with_rooted.send(:rooted_device?)).to be true
    end
  end
end
