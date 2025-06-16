namespace :redis do
  desc "Load whitelist countries into Redis from file"
  task load_country_whitelist: :environment do
    file_path = Rails.root.join('config', 'support_files','country_whitelist.txt')

    unless File.exist?(file_path)
      puts "Whitelist file not found: #{file_path}"
      exit 1
    end

    countries = File.readlines(file_path).map(&:strip).reject(&:empty?)

    RedisCountriesWhitelist.clear
    RedisCountriesWhitelist.load_countries(countries)

    puts "Loaded whitelist countries into Redis: #{RedisCountriesWhitelist.all.join(', ')}"
  end
end