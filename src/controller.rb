require 'sinatra'
require 'sinatra/custom_logger'
require 'sinatra/json'
require 'sinatra/namespace'
require "sinatra/reloader" if development?
require 'json'
require_relative '../db/operation'
require_relative 'password'
require_relative 'token'

enable :logging
disable :show_exceptions

before do
  @payload = JSON.parse(request.body.read)
end

post '/login' do
  user = db_find_user @payload["username"]

  if user && db_password_matched(user, @payload["password"])
    token = generate_token
    db_manager_user_session(user, token)
    return [200, token]
  end

  [500, "username or password incorrect"]
end

namespace '/api' do
  post '/users' do
    user = User.new(username: @payload["username"],
      password: create_password(@payload["password"]))
    user.save
    
    [201, "OK"]
  end
end

error do
  halt 500, {'Content-Type' => 'application/json'}, 
    {message: 'Sorry - ' + env['sinatra.error'].message}.to_json
end
