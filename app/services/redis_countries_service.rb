# Redis Service to manage the country whitelist 

class RedisCountriesService
  
  REDIS_KEY = 'country_whitelist'

  def self.add_country(country_code)
    $redis.sadd(REDIS_KEY, country_code.upcase)
  end

  def self.allowed?(country_code)
    return false if country_code.nil?

    $redis.sismember(REDIS_KEY, country_code.upcase)
  end

  def self.load_countries(countries)
    countries.each { |c| add_country(c) }
  end

  def self.clear
    $redis.del(REDIS_KEY)
  end

  def self.all
    $redis.smembers(REDIS_KEY)
  end
  
end

