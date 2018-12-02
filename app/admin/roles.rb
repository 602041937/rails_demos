ActiveAdmin.register Role do

  form partial: 'form'

  # 注意：要写这个，不然创建不成功
  controller do
    def permitted_params
      params.permit!
    end
  end
end
