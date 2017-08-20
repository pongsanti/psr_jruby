require 'sinatra'
require 'sinatra/custom_logger'
require 'sinatra/json'
require 'sinatra/namespace'
require "sinatra/reloader" if development?
require 'json'
require_relative 'database/connection'
require_relative 'authen/token_auth'
require_relative 'password'
require_relative 'token'

HOST = 'localhost'
PORT = '3306'
DATABASE_NAME = 'sts'
DB_URL = "jdbc:mysql://#{HOST}:#{PORT}/#{DATABASE_NAME}?user=root&password=root&charset=utf8"
DB = SmartTrack::Database.new(DB_URL)

puts 'new db'
puts DB

enable :logging
disable :show_exceptions

include TokenAuth

before do
  req_body = request.body.read
  @payload = JSON.parse(req_body) unless req_body.empty?
end

get '/protected' do
  authorize? env

  puts @user.username

  content_type :json
  json(message: 'This is an authenticated request!')
  end

post '/login' do
  user = DB.db_find_user @payload['username']

  if user && DB.db_password_matched(user, @payload['password'])
    token = generate_token
    DB.db_manager_user_session(user, token)
    return [200, json(token: token)]
  end

  [500, json(message: 'Username or password incorrect')]
end

require_relative 'routes/users'
require_relative 'routes/sessions'

error do
  halt 500, {'Content-Type' => 'application/json'}, 
    {message: 'Sorry - ' + env['sinatra.error'].message}.to_json
end

error UnAuthError do
  halt 500, {}, json(message: 'Unauthorized request')
end
