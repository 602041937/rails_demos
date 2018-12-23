class AppOauthController < ApplicationController

  before_action :doorkeeper_authorize!, only: :callback
  before_action :validate_access_token, only: :user_info

  include UserValidate
  before_action only: :user_info do
    validate_user @item.resource_owner_id
  end

  def login
    @user = User.new
  end

  def deal_login
    current_user = User.where(name: params[:user][:name], password: params[:user][:password]).last
    return render json: {status: 3, messag: "user无效"} if current_user.blank?
    session[:user_id] = current_user.id
    redirect_to(oauth_authorization_url(session[:oauth_params]))
  end

  def callback
    session[:user_id] = 4
    render json: {name: "hpd22"}
  end

  def user_info
    render json: {name: @user.name, age: @user.age}
  end

  private

  def validate_access_token
    access_token = params[:access_token]
    @item = OauthAccessToken.where(token: access_token).last
    return render json: {status: 1, messag: "access_token无效"} if @item.blank?
    if Time.now.to_i > @item.created_at.to_i + @item.expires_in
      return render json: {status: 2, messag: "access_token过期"}
    end
  end
end
