require 'sequel'

HOST = 'localhost'
PORT = '3306'
DATABASE_NAME = 'sts'

DB = Sequel.connect("jdbc:mysql://#{HOST}:#{PORT}/#{DATABASE_NAME}?user=root&password=root&charset=utf8")

DB.extension :identifier_mangling
DB.identifier_input_method = nil
DB.identifier_output_method = nil
DB.quote_identifiers = false

class User < Sequel::Model(:users)
end

class UserSession < Sequel::Model(:user_sessions)
end

