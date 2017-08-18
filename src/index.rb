require 'sinatra'
require "sinatra/json"

post '/api/public/login' do
  data = request.body.read
  json data
end