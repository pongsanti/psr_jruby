require 'sinatra'
require 'sinatra/custom_logger'
require 'sinatra/json'
require 'sinatra/namespace'
require "sinatra/reloader" if development?
require 'json'
require_relative 'db/operation'
require_relative 'authen/token_auth'
require_relative 'password'
require_relative 'token'

enable :logging
disable :show_exceptions

include DbOp
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
  user = db_find_user @payload['username']

  if user && db_password_matched(user, @payload['password'])
    token = generate_token
    db_manager_user_session(user, token)
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
