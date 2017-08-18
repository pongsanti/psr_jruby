require 'sinatra'
require 'sinatra/custom_logger'
require 'sinatra/json'
require 'sinatra/namespace'
require "sinatra/reloader" if development?
require 'json'
require_relative 'model'
require_relative 'password'

enable :logging
disable :show_exceptions

@incoming = 0

post '/login' do
  logger.info "logging in..."
  payload = JSON.parse(request.body.read)

  dataset = User.where { username = payload["username"] }
  
  puts dataset

  json payload
end

namespace '/api' do
  post '/users' do
    logger.info "creating user..."

    # save to db
    payload = JSON.parse(request.body.read)
    u = User.new(username: payload["username"],
      password: create_password(payload["password"]))
    u.save
    
    [201, "OK"]
  end
end

error do
  halt 500, {'Content-Type' => 'application/json'}, 
    {message: 'Sorry - ' + env['sinatra.error'].message}.to_json
end
