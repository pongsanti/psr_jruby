require 'sequel'
require 'mysql-connector-java-5.1.42-bin'

HOST = 'localhost'
PORT = '3306'
DATABASE_NAME = 'sts'

DB = Sequel.connect("jdbc:mysql://#{HOST}:#{PORT}/#{DATABASE_NAME}?user=root&password=root&charset=utf8")

DB.extension :identifier_mangling
DB.identifier_input_method = nil
DB.identifier_output_method = nil
DB.quote_identifiers = false

create_table_options = {charset: 'utf8'}

DB.create_table!(:users, create_table_options) do
  primary_key :id
  String :username
  String :password
  String :display_name
  DateTime :created_at
  DateTime :updated_at
end

DB.create_table!(:user_sessions, create_table_options) do
  primary_key :id
  foreign_key :user_id, :users
  String :token
  DateTime :created_at
  DateTime :updated_at
end

DB.disconnect
