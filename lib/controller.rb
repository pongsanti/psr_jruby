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
  st_container.register(:station_repo, SmartTrack::Database::Repository::StationRepo.new(db_connection.rom))
  st_container.register(:user_station_repo, SmartTrack::Database::Repository::UserStationRepo.new(db_connection.rom))
  st_container.register(:truck_repo, SmartTrack::Database::Repository::TruckRepo.new(db_connection.rom))
  st_container.register(:user_truck_repo, SmartTrack::Database::Repository::UserTruckRepo.new(db_connection.rom))
  st_container.register(:tblhistory_repo, SmartTrack::Database::Repository::TblhistoryRepo.new(db_connection.rom))
  st_container.register(:tblrealtime_repo, SmartTrack::Database::Repository::TblrealtimeRepo.new(db_connection.rom))
  st_container.register(:user_truck_station_repo, SmartTrack::Database::Repository::UserTruckStationRepo.new(db_connection.rom))
end
setup(st_container)

include SmartTrack::TokenAuth

# Hooks
before do
  @rom = st_container.resolve(:rom)
  @sequel = st_container.resolve(:sequel)
  @util = st_container.resolve(:util)
  @user_repo = st_container.resolve(:user_repo)
  @session_repo = st_container.resolve(:session_repo)
  @station_repo = st_container.resolve(:station_repo)
  @user_station_repo = st_container.resolve(:user_station_repo)
  @truck_repo = st_container.resolve(:truck_repo)
  @user_truck_repo = st_container.resolve(:user_truck_repo)
  @tblhistory_repo = st_container.resolve(:tblhistory_repo)
  @tblrealtime_repo = st_container.resolve(:tblrealtime_repo)
  @uts_repo = st_container.resolve(:user_truck_station_repo)

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

helpers do
  def as(col, as)
    Sequel.as(col, as)
  end
  
  def datetime_format datetime
    datetime.strftime('%F %T')
  end
end

require_relative 'routes/login'
require_relative 'routes/user'
require_relative 'routes/sessions'
require_relative 'routes/change_password'
require_relative 'routes/station/get'
require_relative 'routes/user_station'
require_relative 'routes/truck/get'
require_relative 'routes/user_truck'
require_relative 'routes/location/get'
require_relative 'routes/user_truck_station/get'

# Error handling
error do
  halt 500, {'Content-Type' => 'application/json'}, 
    {message: 'Sorry - ' + env['sinatra.error'].message}.to_json
end

error UnAuthError do
  halt 500, {}, json(message: 'Unauthenticated request')
end
