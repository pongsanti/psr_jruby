require 'db/operation'

include DbOp

describe DbOp do
  around(:each) do |example|
    DB.transaction(rollback: :always, auto_savepoint: true) {example.run}
  end

  it 'should find user by username' do
    User.new(username: 'joe', password: 'xxx').save

    user = db_find_user('joe')
    expect(user).to_not be_nil
  end

  it 'should not find user by username' do
    user = db_find_user('mockuser')
    expect(user).to be_nil
  end
end