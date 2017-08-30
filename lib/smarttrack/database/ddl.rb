require 'rom'

module SmartTrack
  module Database
    HOST = 'localhost'
    PORT = '3306'
    DATABASE_NAME = ENV["SINATRA_ENV"] == 'test' ? 'sts_test' : 'sts'
    DB_URL = "jdbc:mysql://#{HOST}:#{PORT}/#{DATABASE_NAME}?user=root&password=root&charset=utf8"

    @rom = ROM.container(:sql, DB_URL) do |conf|
      conf.default.drop_table(:user_sessions, :users)

      conf.default.create_table(:users) do
        primary_key :id
        String :email, null: false, unique: true
        String :password, null: false
        String :display_name
        DateTime :created_at
        DateTime :updated_at
      end

      conf.default.create_table(:user_sessions) do
        primary_key :id
        foreign_key :user_id, :users
        String :token, null: false
        DateTime :expired_at, null: false
        DateTime :created_at
        DateTime :updated_at        
      end

      conf.default.connection['INSERT INTO users (email, password, display_name) VALUES (?, ?, ?)',
        'patima.key@gmail.com', '$2a$10$EiouwUDIvB4ygT5hK2NAG.dAcZuYnETMBKHgbae44oP11unaAjZnS', 'Patima'].insert
    end
  end
end