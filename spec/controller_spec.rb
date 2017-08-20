require 'rack/test'
require 'controller'

describe 'Sts app' do
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  it 'says hello' do
    get '/protected'
    
    expect(last_response.status).to eq(500)
    expect(last_response.body).to include('Unauthorized')
  end
end