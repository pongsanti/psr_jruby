require 'sinatra'
require 'sinatra/config_file'
require 'sinatra/custom_logger'
require 'sinatra/json'
require 'sinatra/namespace'
require "sinatra/reloader" if development?
require 'json'

# puts "env = #{ENV["SINATRA_ENV"]}"
set :environment, :test if ENV["SINATRA_ENV"] == 'test'
# puts development?
# puts test?

require_relative 'smarttrack/database'
require_relative 'smarttrack/model'
require_relative 'authen/token_auth'
require_relative 'password'

enable :logging
disable :show_exceptions

config_file File.expand_path('config/sinatra.yml')

db_url = "jdbc:mysql://#{settings.db_host}:\
#{settings.db_port}/\
#{settings.db_name}?user=root&password=root&charset=utf8"

db_connection = SmartTrack::Database::Connection.new(db_url)
CONN = db_connection.rom
SEQUEL = db_connection.sequel

include SmartTrack::TokenAuth

# Hooks
before do
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
  user_model = SmartTrack::Model::User.new(CONN)
  user = user_model.find_by_email(@payload['email'])
  if user && user_model.password_matched(user.password, @payload['password'])
    user_session_model = SmartTrack::Model::UserSession.new(CONN)
    user_session = user_session_model.find_by_user_id(user.id)

    user_session_model.repo.delete(user_session.id) if user_session
    
    user_session = user_session_model.repo.create(
      token: user_session_model.generate_session_token,
      user_id: user.id,
      expired_at: Time.now + (60*60*24*30))

    return [200, json(token: user_session.token)]
  end

  [500, json(message: 'Email or password incorrect')]
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
