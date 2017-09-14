describe 'Delete user' do
  include_context 'database'

  let(:url) {'/api/users/1'}
  let(:mocktoken) {'mocktoken'}
  let(:req_obj) {
    { display_name: 'New_Guy',
    email: 'new_user@gmail.com',
    password: '1234abcd' }
  }

  context 'in unauthenticated context' do
    it 'cannot delete user' do
      delete url

      expect(last_response.status).to eq(500)
      expect(last_response.body).to include('Unauthen')
    end
  end

  context 'in authenticated non-admin context' do
    before (:each) do
      create_user_session('normal_user@gmail.com', mocktoken)
      header 'X-Authorization', mocktoken
    end

    it 'cannot delete user' do
      delete url

      expect(last_response.status).to eq(500)
      expect(last_response.body).to include('not authorized')
    end
  end

  context 'in authenticated admin context' do
    before(:each) do
      create_admin_user_session('admin@gmail.com', mocktoken)
      header 'X-Authorization', mocktoken
    end

    it 'rejects if user id is not digit' do
      delete '/api/users/abc'

      expect(last_response.status).to eq(500)
      expect(last_response.body).to include('must', 'be', 'integer')
    end

    it 'rejects if user id not existed' do
      delete '/api/users/999'

      expect(last_response.status).to eq(500)
      expect(last_response.body).to include('not existed')
    end    

    it 'can delete user' do
      delete url

      expect(last_response.status).to eq(200)
      expect(user_repo.active_user(1)).to be_nil
    end    
  end
end