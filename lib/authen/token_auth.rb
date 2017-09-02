require 'securerandom'
require_relative 'unauth_error'

module SmartTrack
  module TokenAuth
    def user_repo
      SmartTrack::Database::Container.resolve(:user_repo)
    end

    def session_repo
      SmartTrack::Database::Container.resolve(:session_repo)
    end

    def token env
      env['HTTP_X_AUTHORIZATION']
    end
    
    def authorize? env
      token = token(env) || ''
      raise UnAuthError, "Unauthenticated request" if not token || token.empty?
      
      user_session = session_repo.find_by_token(token)
      if user_session
        halt 500, {}, json(message: 'session expired') if session_expired?(user_session)
        @user = user_session.user
      else
        raise UnAuthError, "Unauthenticated request"
      end
    end

    def session_expired? session
      Time.now >= session.expired_at
    end
  end
end