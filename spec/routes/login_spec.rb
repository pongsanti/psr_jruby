describe 'Login route' do
  include_context 'database'

  let(:email)     { 'john@gmail.com' }
  let(:password)  { '1234' }
  let(:request)   { {email: email, password: password}.to_json }

  context 'in unauthorized user context' do
    it 'can log user in and return token' do
      # prepare
      create_user(email, password)
      # execute
      post_with_json '/login', request
      
      expect(last_response.status).to eq(200)
      expect(last_response.body).to include('token')
    end
  end

  context 'in authorized user context' do
    token = 'mocktoken'
    it 'can log user in and return a new token' do
      # prepare
      user = create_user(email, password)
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
