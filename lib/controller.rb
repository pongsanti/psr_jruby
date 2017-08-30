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

require_relative 'database/connection'
require_relative 'authen/token_auth'
require_relative 'password'

enable :logging
disable :show_exceptions

config_file '../config/sinatra.yml'
DB = SmartTrack::Database::Connection.new("jdbc:mysql://#{settings.db_host}:\
#{settings.db_port}/\
#{settings.db_name}?user=root&password=root&charset=utf8")

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
  user = DB.find_user @payload['email']

  if user && DB.password_matched(user, @payload['password'])
    token = generate_token
    DB.manager_user_session(user, token)
    return [200, json(token: token)]
  end

  [500, json(message: 'Email or password incorrect')]
end

require_relative 'routes/users'
require_relative 'routes/sessions'
require_relative 'routes/change_password'

# Error handling
error do
  halt 500, {'Content-Type' => 'application/json'}, 
    {message: 'Sorry - ' + env['sinatra.error'].message}.to_json
end

error UnAuthError do
  halt 500, {}, json(message: 'Unauthenticated request')
end
