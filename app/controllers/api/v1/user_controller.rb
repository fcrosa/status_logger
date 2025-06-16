module Api

  module V1
  
    class UserController < ApplicationController
  
      def check_status
        cf_ip_country = request.headers['CF-IPCountry']
        rooted_device = params[:rooted_device]
        ip_address = request.remote_ip

        # CF-IPCountry allowed?
        unless RedisCountriesWhitelist.allowed?(cf_ip_country)
          return log_and_ban('CF-IPCountry', cf_ip_country, ip_address, rooted_device)
        end

        # rooted_device?
        if rooted_device
          return log_and_ban('rooted_device', cf_ip_country, ip_address, rooted_device)
        end

        # Validation on VPNAPI
        begin
          api_key = ENV['VPNAPI_KEY']
          vpn_api_url = "https://vpnapi.io/api/#{ip_address}?key=#{api_key}"
          response = HTTP.get(vpn_api_url)
          vpn_data = JSON.parse(response.body.to_s)
          
          if vpn_data['security']['vpn'] || vpn_data['security']['proxy']
            return log_and_ban('VPNAPI', cf_ip_country, ip_address, rooted_device)
          end
        rescue StandardError => e
          Rails.logger.error("VPNAPI error: #{e.message}")
        end
      
        render json: { ban_status: 'not_banned' }, status: :ok
      end

      private

      def log_and_ban(reason, country, ip, rooted_device)
        IntegrityLog.create!(
          idfa: params[:idfa],
          ban_status: 'banned',
          ip: ip,
          rooted_device: rooted_device,
          country: country,
          proxy: false,
          vpn: (reason == 'VPNAPI')
        )
      
        render json: { ban_status: 'banned' }, status: :ok
      end
  
    end
  
  end

end
