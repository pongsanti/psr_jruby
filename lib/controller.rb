require 'sinatra'
require 'sinatra/config_file'
require 'sinatra/custom_logger'
require 'sinatra/json'
require 'sinatra/namespace'
require "sinatra/reloader" if development?
require 'json'
require 'securerandom'
require 'dry-validation'

# puts "env = #{ENV["SINATRA_ENV"]}"
set :environment, :test if ENV["SINATRA_ENV"] == 'test'
# puts development?
# puts test?

require_relative 'smarttrack/database'
require_relative 'smarttrack/constant'
require_relative 'smarttrack/util'
require_relative 'authen/token_auth'
require_relative 'password'

st_container = SmartTrack::Database::Container

enable :logging
disable :show_exceptions
config_file File.expand_path('config/sinatra.yml')

# setup database, container
def setup(st_container)
  db_url = "mysql2://#{settings.db_host}:\
#{settings.db_port}/\
#{settings.db_name}?user=#{settings.db_user}&password=#{settings.db_pass}&charset=utf8"
      
  db_connection = SmartTrack::Database::Connection.new(db_url)
  db_connection.rom.gateways[:default].use_logger(Logger.new($stdout)) if development?

  st_container.register(:util, SmartTrack::Util.new)
  st_container.register(:db_connection, db_connection)
  st_container.register(:rom, db_connection.rom)
  st_container.register(:sequel, db_connection.sequel)
  st_container.register(:user_repo, SmartTrack::Database::Repository::UserRepo.new(db_connection.rom))
  st_container.register(:session_repo, SmartTrack::Database::Repository::UserSessionRepo.new(db_connection.rom))
end
setup(st_container)

include SmartTrack::TokenAuth

# Hooks
before do
  @rom = st_container.resolve(:rom)
  @util = st_container.resolve(:util)
  @user_repo = st_container.resolve(:user_repo)
  @session_repo = st_container.resolve(:session_repo)

  req_body = request.body.read
  @payload = req_body.empty? ? {} : JSON.parse(req_body, symbolize_names: true)
end

after do
  # CORS
  unless request.request_method == 'OPTIONS'
    headers SmartTrack::Constant::CORS_HASH
  end
end

# CORS
options "*" do
  headers SmartTrack::Constant::CORS_HASH
  200
end

# Routes
get '/protected' do
  authorize? env

  content_type :json
  json(message: 'This is an authenticated request!')
end

require_relative 'routes/login'
require_relative 'routes/user'
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
