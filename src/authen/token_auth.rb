require_relative 'unauth_error'

module TokenAuth
  def token env
    env['HTTP_X_AUTHORIZATION']
  end
  
  def authorize? env
    token = token(env)
    return false if token.empty?
    
    user_session = db_find_user_session(token)
    if user_session
      @user = db_find_user_by_id(user_session.user_id)
    else
      raise UnAuthError, "Unauthenticated request"
    end
  end
end