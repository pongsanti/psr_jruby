require 'sequel'

HOST = 'localhost'
PORT = '3306'
DATABASE_NAME = ENV["SINATRA_ENV"] == 'test' ? 'sts_test' : 'sts'

DB = Sequel.connect("jdbc:mysql://#{HOST}:#{PORT}/#{DATABASE_NAME}?user=root&password=root&charset=utf8")

DB.extension :identifier_mangling
DB.identifier_input_method = nil
DB.identifier_output_method = nil
DB.quote_identifiers = false

create_table_options = {charset: 'utf8'}

# Drop tables
DB << 'DROP TABLE user_sessions'
DB << 'DROP TABLE users'

# Create tables
DB.create_table!(:users, create_table_options) do
  primary_key :id
  String :email, null: false, unique: true
  String :password, null: false
  String :display_name
  DateTime :created_at
  DateTime :updated_at
end

DB.create_table!(:user_sessions, create_table_options) do
  primary_key :id
  foreign_key :user_id, :users
  String :token, null: false
  DateTime :expired_at, null: false
  DateTime :created_at
  DateTime :updated_at
end

# Seed data
DB['INSERT INTO users (email, password, display_name) VALUES (?, ?, ?)',
  'patima.key@gmail.com', '$2a$10$EiouwUDIvB4ygT5hK2NAG.dAcZuYnETMBKHgbae44oP11unaAjZnS', 'Patima'].insert

DB.disconnect
