require 'rack/test'
require 'smarttrack'
require_relative '../db_helper'

RSpec.shared_context 'database' do
  def app
    Sinatra::Application
  end
  
  around(:each) do |example|
    SmartTrack::Database::Container.resolve(:sequel)
      .transaction(rollback: :always, auto_savepoint: true) {example.run}
  end
end

RSpec.configure do |config|
  config.include Rack::Test::Methods
  config.include SmartTrack::Test::Helper
end