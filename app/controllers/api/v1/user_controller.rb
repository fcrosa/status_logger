module Api
 
  module V1
 
    class UserController < ApplicationController
 
      def check_status

        errors = []
        params[:ip_address] = request.remote_ip
        errors << 'Missing required headers: CF-IPCountry' if request.headers['CF-IPCountry'].blank?
        errors << 'Missing required body parameters: rooted_device' if params[:rooted_device].to_s.blank?
        errors << 'Missing required body parameters: idfa' if params[:idfa].blank?

        unless errors.empty?
          return render json: { errors: errors }, status: :unprocessable_entity
        end

        # Call the service with all required params/headers
        service = UserStatusService.new(request.headers, params)
        result = service.validate!

        render json: result, status: :ok
      end
    end
  end
end