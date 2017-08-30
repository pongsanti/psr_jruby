require 'rack/test'
require 'smarttrack'
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

  mocktoken = 'mocktoken'
  json_req = {display_name: 'New_Guy',
    email: 'new_user@gmail.com',
    password: '1234abcd'}.to_json

  context 'in unauthenticated context' do
    it 'cannot creates user' do
      post_with_json '/api/users', json_req

      expect(last_response.status).to eq(500)
      expect(last_response.body).to include('Unauthen')
    end
  end

  context 'in authenticated context' do
    it 'can creates new user' do
    
      create_user_session('admin@gmail.com', mocktoken)
      
      header 'X-Authorization', mocktoken
      post_with_json '/api/users', json_req

      expect(last_response.status).to eq(201)
    end
  end
  
end