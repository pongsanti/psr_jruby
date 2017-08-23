require 'controller'
require_relative '../db_helper'

describe SmartTrack::Operation do
  include SmartTrack::Test::Helper

  around(:each) do |example|
    DB.db.transaction(rollback: :always, auto_savepoint: true) {example.run}
  end

  context 'in user existed context' do
    it 'can find user by email' do
      create_user('jane@gmail.com')

      user = DB.find_user('jane@gmail.com')
      expect(user).to_not be_nil
    end
  end

  context 'in user not existed context' do
    it 'cannot find user by email' do
      user = DB.find_user('mockuser')
      expect(user).to be_nil
    end
  end
end