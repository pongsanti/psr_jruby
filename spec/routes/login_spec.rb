require 'rack/test'
require 'controller'
require 'password'
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

  username = 'john@gmail.com'
  password = '1234'
  request = {username: username, password: password}.to_json

  context 'in unauthorized user context' do
    it 'logging user in and return token' do
      # prepare
      create_user(username, create_password(password))
      # execute
      post_with_json '/login', request
      
      expect(last_response.status).to eq(200)
      expect(last_response.body).to include('token')
    end
  end

  context 'in authorized user context' do
    token = 'mocktoken'
    it 'logging user with new token' do
      # prepare
      user = create_user(username, create_password(password))
      create_session(user, token)
      # execute
      post_with_json '/login', request

      expect(last_response.status).to eq(200)
      expect(last_response.body).to include('token')
      new_token_return? token
    end

    def new_token_return? old_token
      json_res = JSON.parse(last_response.body)
      expect(json_res['token']).not_to eq(old_token)
    end
  end

end

# def post_with_json(uri, json)
#   # No assertion in this, we just demonstrate how you can post a JSON-encoded string.
#   # By default, Rack::Test will use HTTP form encoding if you pass in a Hash as the
#   # parameters, so make sure that `json` below is already a JSON-serialized string.
#   post(uri, json, { 'CONTENT_TYPE' => 'application/json' })
# end