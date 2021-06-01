ActiveAdmin.register YouZanOrder do
  permit_params :tid, :outer_item_id, :good_name, :mobile, :pay_type, :pay_time, :created, :all_content

  index do
    selectable_column
    id_column
    column "订单编号", :tid
    column "商品编号", :outer_item_id
    column "商品名称", :good_name
    column "手机号", :mobile
    column "支付方式" do |item|
      if item.pay_type == 2
        "支付宝"
      elsif item.pay_type == 10
        "大账号代销-微信"
      elsif item.pay_type == 16
        "优惠兑换"
      else
        item.pay_type
      end
    end
    column "支付时间", :pay_time
    column "商品数量", :num
    column "商品原价", :price
    column "实际付款", :payment
    column "分销员手机号", :fen_xiao_mobile
    # column "消息内容", :all_content
    actions
  end

end