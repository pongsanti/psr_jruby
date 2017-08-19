require 'sequel'
require_relative 'connection'
require_relative 'model'
require_relative '../password'

module DbOp
  def db_find_user(username)
    return User.where(username: username).first
  end

  def db_password_matched(user, password)
    username = user.username
    hash = new_password_instance(user.password)
    return hash == password
  end

  def db_manager_user_session(user, token)
    user.user_session.delete if user.user_session
    db_insert_user_session(user, token)
  end

  def db_insert_user_session(user, token)
    session = UserSession.new(token: token).save
    user.user_session = session
  end

  def db_delete_user_session(token)
    session = UserSession.where(token: token).first
    session.delete if session
  end
end