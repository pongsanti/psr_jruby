describe 'Post users' do
  include_context 'database'

  let(:url) {'/api/users'}
  let(:mocktoken) {'mocktoken'}
  let(:req_obj) {
    { display_name: 'New_Guy',
    email: 'new_user@gmail.com',
    password: '1234abcd' }
  }
  let(:json_req) {req_obj.to_json}

  context 'in unauthenticated context' do
    it 'cannot creates user' do
      post_with_json '/api/users', json_req

      expect(last_response.status).to eq(500)
      expect(last_response.body).to include('Unauthen')
    end
  end

  context 'in authenticated non-admin context' do
    before (:each) do
      create_user_session('normal_user@gmail.com', mocktoken)
      header 'X-Authorization', mocktoken
    end

    it 'cannot creates user' do
      post_with_json '/api/users', json_req

      expect(last_response.status).to eq(500)
      expect(last_response.body).to include('not authorized')
    end
  end

  context 'in authenticated admin context' do
    before(:each) do
      create_admin_user_session('admin@gmail.com', mocktoken)
      header 'X-Authorization', mocktoken
    end

    it 'rejects if email missing' do
      post_with_json url, req_obj.merge(email: '').to_json

      expect(last_response.status).to eq(500)
      expect(last_response.body).to include('errors', 'email', 'filled')
    end

    it 'rejects if email invalid' do
      post_with_json url, req_obj.merge(email: 'invalid_email').to_json

      expect(last_response.status).to eq(500)
      expect(last_response.body).to include('errors', 'email', 'invalid format')
    end

    it 'rejects if password missing' do
      post_with_json url, req_obj.merge(password: '').to_json

      expect(last_response.status).to eq(500)
      expect(last_response.body).to include('errors', 'password', 'filled')
    end

    it 'rejects if password too short' do
      post_with_json url, req_obj.merge(password: '1234').to_json

      expect(last_response.status).to eq(500)
      expect(last_response.body).to include('errors', 'password', 'size', 'less than')
    end

    it 'rejects if admin is not boolean' do
      post_with_json url, req_obj.merge(admin: 'xxx').to_json
      
      expect(last_response.status).to eq(500)
      expect(last_response.body).to include('errors', 'admin', 'boolean')
    end

    it 'can creates new user' do
      post_with_json url, json_req

      expect(last_response.status).to eq(201)
      expect(last_response.body).to include('OK')
    end

    it 'can creates new admin user' do
      post_with_json url, req_obj.merge(admin: 'true').to_json

      expect(last_response.status).to eq(201)
      expect(last_response.body).to include('OK')

      user = user_repo.find_by_email(req_obj[:email])
      expect(user.admin).to be_truthy
    end    
  end
  
end