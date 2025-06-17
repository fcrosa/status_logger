class UserStatusService

  def initialize(headers, params)
    @cf_ip_country = headers['CF-IPCountry']
    @rooted_device = params[:rooted_device]
    @ip_address = params[:ip_address]
    @idfa = params[:idfa]
  end

  def validate!

    user = find_or_create_user
    return { ban_status: 'banned' } if user.ban_status == 'banned'

    if !country_allowed?
      return log_and_ban('CF-IPCountry', user)
    elsif rooted_device?
      return log_and_ban('rooted_device', user)
    elsif vpn_or_proxy_detected?
      return log_and_ban('VPNAPI', user)
    end

    user.update!(ban_status: 'not_banned')
    { ban_status: 'not_banned' }
  
  end

  private

  def find_or_create_user
    user = User.find_or_initialize_by(idfa: @idfa)
  end

  def country_allowed?
    RedisCountriesService.allowed?(@cf_ip_country)
  end

  def rooted_device?
    @rooted_device==true
  end

  def vpn_or_proxy_detected?
    cache_key = "vpnapi:#{@ip_address}"
    cached_response = $redis.get(cache_key)

    if cached_response
      vpn_data = JSON.parse(cached_response)
    else
      vpn_api_url = "https://vpnapi.io/api/#{@ip_address}?key=#{ENV['VPNAPI_KEY']}"
      response = HTTP.get(vpn_api_url)
      vpn_data = JSON.parse(response.body.to_s)
      # Cache the Redis response for 24 hs
      $redis.setex(cache_key, 24 * 60 * 60, vpn_data.to_json)
    end
    # false || false = false // any other case must return true
    vpn_data['security']['vpn'] || vpn_data['security']['proxy']

  rescue StandardError => e
    
    #If VPNAPI check fails, consider the check as passed.
    Rails.logger.error("VPNAPI error: #{e.message}")
  
    false
  
  end

  def log_and_ban(reason, user)

    Rails.logger.info("User #{user.idfa} banned by: #{reason}")

    IntegrityLoggerService.log(
      idfa: @idfa,
      ban_status: 1,
      ip: @ip_address,
      rooted_device: @rooted_device,
      country: @cf_ip_country,
      proxy: reason == 'VPNAPI',
      vpn: reason == 'VPNAPI'
    )
    user.update!(ban_status: 1)
    
    { ban_status: 'banned' }
    
  end

end
