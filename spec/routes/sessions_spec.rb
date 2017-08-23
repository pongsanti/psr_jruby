require 'rack/test'
require 'controller'
require_relative '../db_helper'

describe 'SmartTrack' do
  include Rack::Test::Methods
  include SmartTrack::Test::Helper

  def app
    Sinatra::Application
  end

  around(:each) do |example|
    DB.db.transaction(rollback: :always, auto_savepoint: true) {example.run}
  end

  context 'in authenticated context' do
    it 'can delete session' do
      token = 'mocktoken'
      create_user_session 'john@gmail.com', token
      
      header 'X-Authorization', token
      delete '/api/sessions'

      expect(last_response.status).to eq(200)
      expect(DB.find_user_session(token)).to be_nil
    end
  end
  
end