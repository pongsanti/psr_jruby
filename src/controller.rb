require 'sinatra'
require 'sinatra/custom_logger'
require 'sinatra/json'
require 'sinatra/namespace'
require "sinatra/reloader" if development?
require 'json'
require_relative 'db/operation'
require_relative 'password'
require_relative 'token'

enable :logging
disable :show_exceptions

include DbOp

before do
  @x_auth_header = request.env["HTTP_X_AUTHORIZATION"]
  @payload = JSON.parse(request.body.read)
end

post '/login' do
  user = db_find_user @payload["username"]

  if user && db_password_matched(user, @payload["password"])
    token = generate_token
    db_manager_user_session(user, token)
    return [200, json(token: token)]
  end

  [500, json(message: "username or password incorrect")]
end

require_relative 'routes/users'
require_relative 'routes/sessions'

error do
  halt 500, {'Content-Type' => 'application/json'}, 
    {message: 'Sorry - ' + env['sinatra.error'].message}.to_json
end
