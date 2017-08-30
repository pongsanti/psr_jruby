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
require_relative 'authen/token_auth'
require_relative 'password'

enable :logging
disable :show_exceptions

config_file File.expand_path('config/sinatra.yml')
rom = SmartTrack::Database::Connection.new("jdbc:mysql://#{settings.db_host}:\
#{settings.db_port}/\
#{settings.db_name}?user=root&password=root&charset=utf8").rom

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
  # user = DB.find_user @payload['email']
  user_repo = SmartTrack::Database::Repository::UserRepo.new(rom)
  user = user_repo.query_first(email: @payload['email'])
  puts user.email
  if user && password_matched(user.password, @payload['password'])
    user_session_repo = SmartTrack::Database::Repository::UserSessionRepo.new(rom)
    user_session = user_session_repo.query_first(user_id: user.id)

    if user_session
      puts user_session.id
      user_session_repo.delete(user_session.id)
    end

    token = generate_token
    user_session = user_session_repo.create(token: token, user_id: user.id, expired_at: Time.now + (60*60*24*30))

    return [200, json(token: user_session.token)]
  end
  
  
  # if user && DB.password_matched(user, @payload['password'])
  #   token = generate_token
  #   DB.manager_user_session(user, token)
  #   return [200, json(token: token)]
  # end

  [500, json(message: 'Email or password incorrect')]
end

def password_matched(user_pass, password)
  hash = new_password_instance(user_pass)
  return hash == password  
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
