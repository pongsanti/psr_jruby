require 'securerandom'
require_relative 'unauth_error'

module SmartTrack
  module TokenAuth
    def token env
      env['HTTP_X_AUTHORIZATION']
    end
    
    def authorize? env
      token = token(env) || ''
      raise UnAuthError, "Unauthenticated request" if not token || token.empty?
      
      user_session = DB.find_user_session(token)
      if user_session
        @user = DB.find_user_by_id(user_session.user_id)
      else
        raise UnAuthError, "Unauthenticated request"
      end
    end

    def generate_token
      SecureRandom.uuid
    end

    def expire_at
      
    end
  end
end