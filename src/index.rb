require 'sinatra'
require 'sinatra/custom_logger'
require 'sinatra/json'
require 'sinatra/namespace'
require "sinatra/reloader" if development?
require 'logger'
require 'json'

set :logger, Logger.new(STDOUT)

post '/login' do
  logger.info "logging in..."
  data = request.body.read
  json data
end

namespace '/api' do
  post '/users' do
    logger.info "creating user..."
    payload = JSON.parse(request.body.read)
    puts payload["username"]
  end
end
