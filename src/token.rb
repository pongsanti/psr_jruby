require 'securerandom'

def generate_token
  SecureRandom.uuid
end