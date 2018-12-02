class RoleAssignment < ApplicationRecord
  belongs_to :admin_user
  belongs_to :role
end
