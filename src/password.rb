require 'bcrypt'

def create_password(pass)
  BCrypt::Password.create(pass)
end