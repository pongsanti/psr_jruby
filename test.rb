require 'rom'
require 'rom-repository'

db_url = "jdbc:mysql://localhost:3306/sts?user=root&password=root&charset=utf8"

config = ROM::Configuration.new(:sql, db_url)

class Users < ROM::Relation[:sql]
  schema(infer: true) do
    associations do
      has_one :user_session
    end
  end
end

class UserSessions < ROM::Relation[:sql]
  schema(infer: true) do
    associations do
      belongs_to :user
    end
  end

  def index
    select(:id, :token)
  end

  def with_user
    join(:user)
  end

  puts 'relation loaded.....'
end

config.register_relation(Users)
config.register_relation(UserSessions)

rom = ROM.container(config)
rom.gateways[:default].use_logger(Logger.new($stdout))


class UserSessionRepo < ROM::Repository[:user_sessions]
  relations :users

  commands :create, delete: :by_pk

  def query_first(conditions)
    #user_sessions.where(conditions).first
    # puts self
    # puts self.inspect
    # puts user_sessions
    # puts user_sessions.inspect
    # puts
    #user_sessions.index.wrap_parent(user: users).where(conditions).first
    user_sessions.wrap(:user).where(conditions).first
  end
end

user_session_repo = UserSessionRepo.new(rom)
user_session = user_session_repo.query_first(user_id: 1)
puts user_session.id
puts user_session.token
puts user_session.user
