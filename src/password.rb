require 'bcrypt'

def create_password(pass)
  BCrypt::Password.create(pass)
end

def new_password_instance(pass)
  BCrypt::Password.new(pass)
end