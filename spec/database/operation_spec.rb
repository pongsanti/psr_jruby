require 'controller'

describe SmartTrack::Operation do

  around(:each) do |example|
    DB.db.transaction(rollback: :always, auto_savepoint: true) {example.run}
  end

  it 'should find user by username' do
    SmartTrack::User.new(username: 'jane@gmail.com', password: 'xxx').save

    user = DB.find_user('jane@gmail.com')
    expect(user).to_not be_nil
  end

  it 'should not find user by username' do
    user = DB.find_user('mockuser')
    expect(user).to be_nil
  end
end