require 'rails_helper'

# To run this test, you must have Redis configured in your local environment correctly 
# and the Redis service running.

RSpec.describe RedisCountriesWhitelist do
  
  let(:redis_key) { described_class::REDIS_KEY }

  before(:each) do
    # Clear the list before run each test
    $redis.del(redis_key)
  end

  describe '.add_country' do
  
    it 'adds a country code to the Redis set' do
  
      described_class.add_country('us')
      expect($redis.sismember(redis_key, 'US')).to be true
    end

    it 'stores country codes in uppercase' do
  
      described_class.add_country('br')
      expect($redis.smembers(redis_key)).to include('BR')
    end
  end

  describe '.allowed?' do
  
    before do
      described_class.add_country('US')
    end

    it 'returns true if country code is in whitelist' do
      expect(described_class.allowed?('US')).to be true
      expect(described_class.allowed?('us')).to be true
    end

    it 'returns false if country code is nil' do
      expect(described_class.allowed?(nil)).to be false
    end

    it 'returns false if country code is not in whitelist' do
      expect(described_class.allowed?('FR')).to be false
    end
  end

  describe '.load_countries' do

    it 'adds multiple countries to the whitelist' do
    
      countries = ['US', 'BR', 'FR']
      described_class.load_countries(countries)

      expect(described_class.all).to include('US', 'BR', 'FR')
    end
  end

  describe '.clear' do
    
    it 'clears all countries from the whitelist' do
    
      described_class.add_country('US')
      expect(described_class.all).to include('US')

      described_class.clear
      expect(described_class.all).to be_empty
    end
  end

  describe '.all' do
    
    it 'returns all countries in the whitelist' do
    
      described_class.add_country('US')
      described_class.add_country('BR')

      expect(described_class.all).to match_array(['US', 'BR'])
    end
  end
end
