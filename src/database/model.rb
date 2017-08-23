module SmartTrack
  class Sequel::Model
    def before_create
      self.created_at ||= Time.now
      super
    end
  
    def before_update
      self.updated_at ||= Time.now
      super
    end
  end

  class User < Sequel::Model(:users)
    one_to_one :user_session
    plugin :validation_helpers
    def validate
      super
      validates_presence [:email, :password]
      validates_format /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i, :email
    end
  end

  class UserSession < Sequel::Model(:user_sessions)
    many_to_one :user
  end
end
