class CreateYouZanOrders < ActiveRecord::Migration[5.2]
  def change
    create_table :you_zan_orders do |t|
      t.string :tid
      t.string :outer_item_id
      t.string :good_name
      t.string :mobile
      t.string :num
      t.string :price
      t.string :payment
      t.string :fen_xiao_mobile
      t.integer :pay_type
      t.string :pay_time
      t.string :created
      t.string :all_content
      t.timestamps
    end
  end
end
