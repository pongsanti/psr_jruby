require 'securerandom'

module SmartTrack::Model
  class UserSession
    attr_accessor :rom, :repo

    def initialize(rom)
      @rom = rom
      @repo = SmartTrack::Database::Repository::UserSessionRepo.new(rom)
    end

    def find_by_user_id(user_id)
      repo.query_first(user_id: user_id)
    end

    def generate_session_token
      SecureRandom.uuid
    end
  end
end