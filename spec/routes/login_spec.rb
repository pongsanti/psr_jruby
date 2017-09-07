describe 'Login route' do
  include_context 'database'

  let(:email)     { 'john@gmail.com' }
  let(:password)  { '1234' }
  let(:request)   { {email: email, password: password}.to_json }

  context 'for all context' do
    it 'requires email' do
      post_with_json '/login', {password: 'pass'}.to_json

      expect(last_response.status).to eq(500)
      expect(last_response.body).to include('errors', 'email')
      expect(last_response.body).not_to include('password')
    end

    it 'requires email with correct format' do
      post_with_json '/login', {email: 'invalid_email', password: 'pass'}.to_json

      expect(last_response.status).to eq(500)
      expect(last_response.body).to include('errors', 'email')
      expect(last_response.body).not_to include('password')
    end

    it 'requires password' do
      post_with_json '/login', {email: 'john@email.com'}.to_json

      expect(last_response.status).to eq(500)
      expect(last_response.body).to include('errors', 'password')
      expect(last_response.body).not_to include('email')
    end       
  end

  context 'in unauthorized user context' do
    it 'can log user in and return token' do
      # prepare
      create_user(email, password)
      # execute
      post_with_json '/login', request
      
      expect(last_response.status).to eq(200)
      expect(last_response.body).to include('token')
      expect(last_response.body).to include('user')
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
      expect(last_response.body).to include('user')
      new_token_return? token
    end

    def new_token_return? old_token
      json_res = JSON.parse(last_response.body)
      expect(json_res['token']).not_to eq(old_token)
    end
  end

end
