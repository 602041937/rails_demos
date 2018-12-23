module UserValidate
  extend ActiveSupport::Concern

  def validate_user user_id
    @user = User.find_by_id(user_id)
    return render json: {status: 3, messag: "user无效"} if @user.blank?
  end
end