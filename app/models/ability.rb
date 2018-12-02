class Ability
  include CanCan::Ability

  def initialize(user)
    user.computed_permissions.call(self, user)
    can :read, ActiveAdmin::Page, name: "Dashboard", namespace_name: "admin"
  end
end
