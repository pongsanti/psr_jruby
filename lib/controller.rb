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
require_relative 'authen/token_auth'
require_relative 'password'

enable :logging
disable :show_exceptions
config_file File.expand_path('config/sinatra.yml')

# setup database, container
def setup
  db_url = "jdbc:mysql://#{settings.db_host}:\
#{settings.db_port}/\
#{settings.db_name}?user=root&password=root&charset=utf8"
      
  db_connection = SmartTrack::Database::Connection.new(db_url)
  db_connection.rom.gateways[:default].use_logger(Logger.new($stdout)) if development?

  SmartTrack::Database::Container.register(:db_connection, db_connection)
  SmartTrack::Database::Container.register(:rom, db_connection.rom)
  SmartTrack::Database::Container.register(:sequel, db_connection.sequel)
  SmartTrack::Database::Container.register(:user_repo, SmartTrack::Database::Repository::UserRepo.new(db_connection.rom))
  SmartTrack::Database::Container.register(:session_repo, SmartTrack::Database::Repository::UserSessionRepo.new(db_connection.rom))
end
setup

include SmartTrack::TokenAuth

# Hooks
before do
  @rom = SmartTrack::Database::Container.resolve(:rom)
  @user_repo = SmartTrack::Database::Container.resolve(:user_repo)
  @session_repo = SmartTrack::Database::Container.resolve(:session_repo)

  req_body = request.body.read
  @payload = JSON.parse(req_body, symbolize_names: true) unless req_body.empty?
end

# Routes
get '/protected' do
  authorize? env

  content_type :json
  json(message: 'This is an authenticated request!')
end

require_relative 'routes/login'
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
