require 'rack/test'
require 'smarttrack'
require_relative 'db_helper'

describe 'SmartTrack' do
  include Rack::Test::Methods
  include SmartTrack::Test::Helper

  def app
    Sinatra::Application
  end

  around(:each) do |example|
    DB.db.transaction(rollback: :always, auto_savepoint: true) {example.run}
  end

  context 'in unauthorized user context' do
    it 'cannot access authorized page' do
      get '/protected'
      
      expect(last_response.status).to eq(500)
      expect(last_response.body).to include('Unauthenticated')
    end
  end

  context 'in authorized user context' do
    token = 'mocktoken'

    it 'can access authorized page' do
      create_user_session 'john@gmail.com', token
      
      header 'X-Authorization', token
      get '/protected'

      expect(last_response.status).to eq(200)
      expect(last_response.body).to include('authenticated')
    end
  end
end