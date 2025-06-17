namespace :redis do
  desc "Load whitelist countries into Redis from environment variable"
  task load_country_whitelist: :environment do
    whitelist = ENV["WL_COUNTRIES"]

    if whitelist.blank?
      puts "Whitelist environment variable not found or empty: WL_COUNTRIES"
      exit 1
    end

    countries = whitelist.split(',').map(&:strip).reject(&:empty?)

    RedisCountriesService.clear
    RedisCountriesService.load_countries(countries)

    puts "Loaded whitelist countries into Redis: #{RedisCountriesService.all.join(', ')}"
  end
end