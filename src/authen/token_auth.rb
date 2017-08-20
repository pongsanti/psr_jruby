require_relative 'unauth_error'

module TokenAuth
  def token env
    env['HTTP_X_AUTHORIZATION']
  end
  
  def authorize? env
    token = token(env) || ''
    raise UnAuthError, "Unauthenticated request" if not token || token.empty?
    
    user_session = DB.db_find_user_session(token)
    if user_session
      @user = DB.db_find_user_by_id(user_session.user_id)
    else
      raise UnAuthError, "Unauthenticated request"
    end
  end
end