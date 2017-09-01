require 'sinatra'
require 'sinatra/config_file'
require 'sinatra/custom_logger'
require 'sinatra/json'
require 'sinatra/namespace'
require "sinatra/reloader" if development?
require 'json'
require 'securerandom'

# puts "env = #{ENV["SINATRA_ENV"]}"
set :environment, :test if ENV["SINATRA_ENV"] == 'test'
# puts development?
# puts test?

require_relative 'smarttrack/database'
require_relative 'authen/token_auth'
require_relative 'password'

enable :logging
disable :show_exceptions

config_file File.expand_path('config/sinatra.yml')

db_url = "jdbc:mysql://#{settings.db_host}:\
#{settings.db_port}/\
#{settings.db_name}?user=root&password=root&charset=utf8"

db_connection = SmartTrack::Database::Connection.new(db_url)
db_connection.rom.gateways[:default].use_logger(Logger.new($stdout)) if development?

SmartTrack::Database::Container.register(:db_connection, db_connection)
SmartTrack::Database::Container.register(:rom, db_connection.rom)
SmartTrack::Database::Container.register(:sequel, db_connection.sequel)

include SmartTrack::TokenAuth

# Hooks
before do
  @rom = SmartTrack::Database::Container.resolve(:rom)
  
  req_body = request.body.read
  @payload = JSON.parse(req_body) unless req_body.empty?
end

# Routes
get '/protected' do
  authorize? env

  content_type :json
  json(message: 'This is an authenticated request!')
end

post '/login' do
  user_repo = SmartTrack::Database::Repository::UserRepo.new(@rom)
  session_repo = SmartTrack::Database::Repository::UserSessionRepo.new(@rom)
  user = user_repo.find_by_email(@payload['email'])

  if user && password_matched(user.password, @payload['password'])
    user_session = session_repo.find_by_user_id(user.id)
    session_repo.delete(user_session.id) if user_session
    
    user_session = session_repo.create(
      token: generate_session_token,
      user_id: user.id,
      expired_at: Time.now + (60*60*24*30))

    return [200, json(token: user_session.token)]
  end

  [500, json(message: 'Email or password incorrect')]
end

def generate_session_token
  SecureRandom.uuid
end

def password_matched(user_pass_hash, external_password)
  hash = BCrypt::Password.new(user_pass_hash)
  return hash == external_password  
end

# require_relative 'routes/users'
# require_relative 'routes/sessions'
# require_relative 'routes/change_password'

# Error handling
error do
  halt 500, {'Content-Type' => 'application/json'}, 
    {message: 'Sorry - ' + env['sinatra.error'].message}.to_json
end

error UnAuthError do
  halt 500, {}, json(message: 'Unauthenticated request')
end
