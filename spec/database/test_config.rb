module SmartTrack
  module Test
    HOST = 'localhost'
    PORT = '3306'
    DATABASE_NAME = 'sts_test'
    DB_URL = "jdbc:mysql://#{HOST}:#{PORT}/#{DATABASE_NAME}?user=root&password=root&charset=utf8"
  end
end
