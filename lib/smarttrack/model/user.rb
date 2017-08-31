require 'bcrypt'

module SmartTrack::Model
  class User
    attr_accessor :rom, :repo

    def initialize(rom)
      @rom = rom
      @repo = SmartTrack::Database::Repository::UserRepo.new(rom)
    end

    def find_by_email(email)
      repo.query_first(email: email)
    end

    def password_matched(user_pass_hash, external_password)
      hash = BCrypt::Password.new(user_pass_hash)
      return hash == external_password  
    end
  end
end