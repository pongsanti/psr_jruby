require 'db/operation'

include DbOp

describe DbOp do
  it 'should find user by username' do
    user = db_find_user('patima.key@gmail.com')
    expect(user).to be_nil
  end
end