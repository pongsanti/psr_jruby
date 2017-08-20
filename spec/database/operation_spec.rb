require 'database/base'

# HOST = 'localhost'
# PORT = '3306'
# DATABASE_NAME = 'sts'
# DB_URL = "jdbc:mysql://#{HOST}:#{PORT}/#{DATABASE_NAME}?user=root&password=root&charset=utf8"

describe SmartTrack::Operation do
  before(:all) do
    @db = SmartTrack::Database.new(DB_URL)
  end

  around(:each) do |example|
    @db.db.transaction(rollback: :always, auto_savepoint: true) {example.run}
  end

  it 'should find user by username' do
    SmartTrack::User.new(username: 'joe', password: 'xxx').save

    user = @db.db_find_user('joe')
    expect(user).to_not be_nil
  end

  it 'should not find user by username' do
    user = @db.db_find_user('mockuser')
    expect(user).to be_nil
  end
end