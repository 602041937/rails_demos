class ApplicationController < ActionController::Base
  protect_from_forgery

  # cancanadapter，访问被拒绝后会回调这个方法
  def access_denied(exception)
    redirect_to admin_root_path, alert: exception.message
  end

  # cancanadapter，访问被拒绝后会回调这个方法，上面的那个方法无效，提示多了个参数（暂不知原因）
  def access_denied
    redirect_to admin_root_path, alert: "您没有权限访问！"
  end
end
