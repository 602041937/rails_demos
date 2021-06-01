require 'open-uri'

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

  def test
    yzorder = YouZanOrder.new
    yzorder.save!

    render json: {status: 0}
  end

  def tradeTradeSuccess
    params = params
    p params
    render json: {status: 0}
  end


  def push
    # 先判断购买成功的type，这里没体现
    body_read = request.body.read
    body_json = JSON.parse body_read
    msg = body_json["msg"]
    msg_decode = URI::decode msg
    msg_json = JSON.parse msg_decode
    full_order_info = msg_json["full_order_info"]
    order = full_order_info["orders"][0]
    #商品名称
    good_name = order["title"]
    # 商品对应编码
    outer_item_id = order["outer_item_id"]
    # 商品留言
    item_message = order["item_message"]
    item_message_json = JSON.parse item_message
    # 留言手机号
    mobile = item_message_json["雅思哥账号"]
    # 商品数量
    num = order["num"]
    # 商品原价
    price = order["price"]
    # 实际付款价格
    payment = order["payment"]

    order_info = full_order_info["order_info"]
    # 订单号
    tid = order_info["tid"]
    # 支付方式
    pay_type = order_info["pay_type"]
    # 支付时间
    pay_time = order_info["pay_time"]
    # 订单创建时间
    created = order_info["created"]

    yzorder = YouZanOrder.new
    yzorder.tid = tid
    yzorder.num = num
    yzorder.price = price
    yzorder.payment = payment
    yzorder.outer_item_id = outer_item_id
    yzorder.good_name = good_name
    yzorder.mobile = mobile
    # yzorder.zone = zone
    yzorder.pay_type = pay_type
    yzorder.pay_time = pay_time
    yzorder.created = created
    yzorder.all_content = body_read
    yzorder.save!

    access_token = "d2500e0f46d669c959c6aaff2fea9eb"
    RestClient.post("https://open.youzanyun.com/api/youzan.salesman.trades.account.get/3.0.0?access_token=#{access_token}",
                    {order_no: tid}.to_json, :content_type => 'application/json') {|response, request, result, &block|
      if response.code == 200
        body = response.body
        body_json = JSON.parse body
        code = body_json["code"]
        if code == 200
          data = body_json["data"]
          mobile = data["mobile"]
          yzorder.fen_xiao_mobile = mobile
          yzorder.save!
        end
      end

      render json: {code: 0, msg: "success"}
    }
  end

  def getYouZanToken
    #d2500e0f46d669c959c6aaff2fea9eb
    RestClient.post("https://open.youzanyun.com/auth/token",
                    {client_id: "d259ac4afc33521d0e",
                     client_secret: "1cec8550851368a6939391e0f917dc47",
                     authorize_type: "silent",
                     grant_id: "41418008",
                     refresh: false}.to_json, :content_type => 'application/json') {|response, request, result, &block|
      if response.code == 200
        return render json: response.body
      else
        return json_response(nil, JSON(response.body)["message"] || "数据错误", 400)
      end
    }
  end

  #
  def get_fenxiao_info

    access_token = "d2500e0f46d669c959c6aaff2fea9eb"
    RestClient.post("https://open.youzanyun.com/api/youzan.salesman.trades.account.get/3.0.0?access_token=#{access_token}",
                    {order_no: "E20210601174736092304097"}.to_json, :content_type => 'application/json') {|response, request, result, &block|
      if response.code == 200
        body = response.body
        body_json = JSON.parse body
        code = body_json["code"]
        if code == 200
          data = body_json["data"]
          mobile = data["mobile"]
        end
        return render json: response.body
      else
        return json_response(nil, JSON(response.body)["message"] || "数据错误", 400)
      end
    }
  end

  def get_fenxiaoer_detail
    access_token = "d2500e0f46d669c959c6aaff2fea9eb"
    RestClient.post("https://open.youzanyun.com/api/youzan.salesman.account.get/3.0.1?access_token=#{access_token}",
                    {mobile: "13076906386"}.to_json, :content_type => 'application/json') {|response, request, result, &block|
      if response.code == 200
        return render json: response.body
      else
        return json_response(nil, JSON(response.body)["message"] || "数据错误", 400)
      end
    }
  end
end
