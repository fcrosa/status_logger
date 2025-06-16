Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      post 'user/check_status', to: 'user#check_status'
    end
  end
end