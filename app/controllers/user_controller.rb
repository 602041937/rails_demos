class UserController < ApplicationController

  def test
    render json: {data: "hpd"}
  end
end
