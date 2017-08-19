require 'sequel'

class User < Sequel::Model(:users)
  one_to_one :user_session
  plugin :validation_helpers
  def validate
    super
    validates_presence [:username, :password]
  end
end

class UserSession < Sequel::Model(:user_sessions)
end



