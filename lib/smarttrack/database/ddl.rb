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

    @rom = ROM.container(:sql, DB_URL) do |conf|
      begin
        conf.default.drop_table(:user_sessions, :users)
      rescue
        # do nothing
      end

      conf.default.create_table(:users) do
        primary_key :id
        String :email, null: false, unique: true
        String :password, null: false
        String :display_name
        TrueClass :admin, null: false, default: false
        DateTime :created_at
        DateTime :updated_at
        DateTime :deleted_at
      end

      conf.default.create_table(:user_sessions) do
        primary_key :id
        foreign_key :user_id, :users
        String :token, null: false
        DateTime :expired_at, null: false
        DateTime :created_at
        DateTime :updated_at        
      end

      connection = conf.default.connection
      connection['INSERT INTO users (email, password, display_name) VALUES (?, ?, ?)',
        'ruchira@pongsiri.co.th', BCrypt::Password.create('1a2b3c4d5e'), 'Ruchira T.'].insert
      connection['INSERT INTO users (email, password, display_name, admin) VALUES (?, ?, ?, ?)',
        'popsicle@gmail.com', BCrypt::Password.create('1234'), 'Popsicle', true].insert        
    end
  end
end