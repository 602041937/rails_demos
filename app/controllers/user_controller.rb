class UserController < ApplicationController

  def test
    return render json: {data: "hpd"}
  end
end
