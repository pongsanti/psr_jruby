require 'bcrypt'

class SmartTrack::Util
  ONE_MONTH_IN_MS = (60*60*24*30)

  def generate_session_token
    SecureRandom.uuid
  end
  
  def password_matched(user_pass_hash, external_password)
    hash = BCrypt::Password.new(user_pass_hash)
    return hash == external_password  
  end
end
