# frozen_string_literal: true

class Role < RoleCore::Role
  # AdminUser与Role多对多
  has_many :role_assignments, dependent: :destroy
  has_many :admin_users, through: :role_assignments
end
