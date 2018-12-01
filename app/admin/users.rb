ActiveAdmin.register User do
  permit_params :name, :password, :age
end
