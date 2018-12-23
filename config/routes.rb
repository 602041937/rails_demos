Rails.application.routes.draw do

  root to: 'application#index'

  # use_doorkeeper 自动生成一下路由
  # GET       /oauth/authorize/native?code
  # GET       /oauth/authorize
  # POST      /oauth/authorize
  # DELETE    /oauth/authorize
  # POST      /oauth/token
  # POST      /oauth/revoke
  # POST      /oauth/introspect
  # resources /oauth/applications
  # GET       /oauth/authorized_applications
  # DELETE    /oauth/authorized_applications/:id
  # GET       /oauth/token/info
  use_doorkeeper

  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  get 'user/test'

  get 'app_oauth/login'
  post 'app_oauth/deal_login'

  get 'app_oauth/callback'
  get 'app_oauth/user_info'

end
