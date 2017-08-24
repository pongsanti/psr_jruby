require 'bcrypt'

def create_password(pass)
  BCrypt::Password.create(pass)
end

def new_password_instance(hash)
  BCrypt::Password.new(hash)
end