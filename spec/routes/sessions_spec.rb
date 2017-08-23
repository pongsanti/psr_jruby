require 'rack/test'
require 'controller'

describe 'SmartTrack' do
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  around(:each) do |example|
    DB.db.transaction(rollback: :always, auto_savepoint: true) {example.run}
  end

  context 'in authenticated context' do
    it 'can delete session' do
      token = 'mocktoken'
      user = SmartTrack::User.new(username: 'john@gmail.com', password: 'xxx').save
      DB.insert_user_session(user, token)
      
      header 'X-Authorization', token
      delete '/api/sessions'

      expect(last_response.status).to eq(200)
      expect(DB.find_user_session(token)).to be_nil
    end
  end
  
end