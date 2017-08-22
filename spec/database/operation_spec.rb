require_relative 'test_config'
include SmartTrack::Test

require 'database/base'

describe SmartTrack::Operation do
  before(:all) do
    @db = SmartTrack::Database.new(DB_TEST_URL)
  end

  around(:each) do |example|
    @db.db.transaction(rollback: :always, auto_savepoint: true) {example.run}
  end

  it 'should find user by username' do
    SmartTrack::User.new(username: 'joe', password: 'xxx').save

    user = @db.find_user('joe')
    expect(user).to_not be_nil
  end

  it 'should not find user by username' do
    user = @db.find_user('mockuser')
    expect(user).to be_nil
  end
end