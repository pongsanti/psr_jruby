require 'rack/test'
require 'controller'

describe 'Sts app' do
  include Rack::Test::Methods

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
      expect(last_response.body).to include('Unauthorized')
    end
  end

  context 'in authorized user context' do
    token = 'mocktoken'

    it 'can access authorized page' do
      user = SmartTrack::User.new(username: 'john@gmail.com', password: 'xxx').save
      DB.insert_user_session(user, token)
      
      header 'X-Authorization', token
      get '/protected'

      expect(last_response.status).to eq(200)
      expect(last_response.body).to include('authenticated')
    end
  end
end