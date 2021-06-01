Rails.application.routes.draw do
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  get '/test', to: "application#test"

  get '/trade_TradeSuccess', to: "application#tradeTradeSuccess"

  get '/getYouZanToken',to: "application#getYouZanToken"

  get '/get_fenxiao_info',to: "application#get_fenxiao_info"

  get '/get_fenxiaoer_detail',to: "application#get_fenxiaoer_detail"

  post '/push', to: "application#push"
end
