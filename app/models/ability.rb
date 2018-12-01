class Ability
  include CanCan::Ability

  def initialize(user)
    p "hpdhpd"
    can :manage, :all
    cannot :read, User
  end
end
