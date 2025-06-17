# Initializer for redis_countries_whitelist.rb
require_dependency Rails.root.join('app', 'services', 'redis_countries_service').to_s

if ENV["WL_COUNTRIES"].present?
  countries = ENV["WL_COUNTRIES"].split(',').map(&:strip).reject(&:empty?)
  RedisCountriesService.clear
  RedisCountriesService.load_countries(countries)
  Rails.logger.info("Loaded whitelist countries into Redis: #{RedisCountriesService.all.join(', ')}")
else
  Rails.logger.warn("Whitelist countries not set in ENV['WL_COUNTRIES']")
end
