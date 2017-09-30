require 'rom'
require 'bcrypt'

module SmartTrack
  module Database
    HOST = 'localhost'
    PORT = '3306'
    DATABASE_NAME = ENV["SINATRA_ENV"] == 'test' ? 'smarttrack_test' : 'smarttrack'
    USER = 'root'
    PASS = 'root'
    DB_URL = "mysql2://#{HOST}:#{PORT}/#{DATABASE_NAME}?user=#{USER}&password=#{PASS}&charset=utf8"
    TH_TRACKING_DB_NAME = ENV['TH_TRACKING_DB_NAME']

    @rom = ROM.container(:sql, DB_URL) do |conf|
      conf.default.use_logger(Logger.new($stdout))
      
       
      conf.default.connection.drop_table?( 
        :user_sessions,
        :user_stations,
        :user_trucks,
        :users)
      begin
        conf.default.connection.drop_view(:stations)
        conf.default.connection.drop_view(:tblcarsets)
        conf.default.connection.drop_view(:tblrealtimes)
        conf.default.connection.drop_view(:tblhistories)
      rescue; end

      conf.default.create_table(:users, charset: 'tis620') do
        primary_key :id
        String :email, null: false, unique: true
        String :password, null: false
        String :display_name
        TrueClass :admin, null: false, default: false
        DateTime :created_at
        DateTime :updated_at
        DateTime :deleted_at
      end

      conf.default.create_table(:user_sessions, charset: 'tis620') do
        primary_key :id
        foreign_key :user_id, :users
        String :token, null: false
        DateTime :expired_at, null: false
        DateTime :created_at
        DateTime :updated_at        
      end
      
      conf.default.create_table(:user_stations, charset: 'tis620') do
        foreign_key :user_id, :users
        Integer :station_id, null: false
        
        primary_key [:user_id, :station_id]
      end

      conf.default.connection.create_or_replace_view(:stations, "SELECT * FROM `#{TH_TRACKING_DB_NAME}`.`tblstation`")

      conf.default.create_table(:user_trucks, charset: 'tis620') do
        primary_key :id
        foreign_key :user_id, :users, null: false
        Integer :truck_id,  null: false
        DateTime :start_at, null: false
        DateTime :end_at,   null: false
        DateTime :created_at
        DateTime :updated_at
        DateTime :deleted_at
      end

      conf.default.connection.create_or_replace_view(:tblcarsets, "SELECT * FROM `#{TH_TRACKING_DB_NAME}`.`tblcarset` WHERE groupid = 1000")
      conf.default.connection.create_or_replace_view(:tblrealtimes, "SELECT * FROM `#{TH_TRACKING_DB_NAME}`.`tblrealtime`")
      conf.default.connection.create_or_replace_view(:tblhistories, "SELECT * FROM `#{TH_TRACKING_DB_NAME}`.`tblhistory`")

      conf.default.create_table(:user_truck_stations, charset: 'tis620') do
        primary_key :id
        foreign_key :user_truck_id, :user_trucks, null: false
        Integer :station_id,  null: false
        DateTime :arrived_at, null: false
        DateTime :departed_at
        DateTime :created_at
        DateTime :updated_at
        DateTime :deleted_at
      end      
      
      connection = conf.default.connection
      connection['INSERT INTO users (email, password, display_name) VALUES (?, ?, ?)',
        'ruchira@pongsiri.co.th', BCrypt::Password.create('1a2b3c4d5e'), 'Ruchira T.'].insert
      connection['INSERT INTO users (email, password, display_name, admin) VALUES (?, ?, ?, ?)',
        'popsicle@gmail.com', BCrypt::Password.create('1234'), 'Popsicle', true].insert

      connection['INSERT INTO user_stations (user_id, station_id) VALUES (?, ?)',
        1, 1].insert
      connection['INSERT INTO user_stations (user_id, station_id) VALUES (?, ?)',
        1, 2].insert        
    end
  end
end