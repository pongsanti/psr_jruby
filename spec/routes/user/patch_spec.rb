describe 'Patch user' do
  include_context 'database'

  let(:url) {'/api/users/1'}
  let(:mocktoken) {'mocktoken'}
  let(:req_obj) {
    { display_name: 'New_Guy',
    email: 'new_user@gmail.com' }
  }  

  context 'in unauthenticated context' do
    it 'cannot patch user' do
      patch url

      expect(last_response.status).to eq(500)
      expect(last_response.body).to include('Unauthen')
    end
  end

  context 'in authenticated non-admin context' do
    before(:each) do
      create_user_session('normal_user@gmail.com', mocktoken)
      header 'X-Authorization', mocktoken
    end

    it 'cannot patch user' do
      patch url

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
      patch '/api/users/abc'

      expect(last_response.status).to eq(500)
      expect(last_response.body).to include('must', 'be', 'integer')
    end

    it 'rejects if new email already existed' do
      patch url, req_obj.merge({email: 'admin@gmail.com'}).to_json

      expect(last_response.status).to eq(500)
      expect(last_response.body).to include('Email', 'existed')
    end

    it 'rejects if user id not existed' do
      patch '/api/users/9999'

      expect(last_response.status).to eq(500)
      expect(last_response.body).to include('not existed')
    end

    it 'can patch user' do
      patch url, req_obj.to_json

      expect(last_response.status).to eq(200)
      expect(last_response.body).to include('OK')

      user = user_repo.find_by_email(req_obj[:email])
      expect(user.display_name).to eql(req_obj[:display_name])
    end

    it 'can patch partial user field' do
      user = user_repo.active_user(1)

      patch url, {admin: true}.to_json
      user = user_repo.active_user(1)
      expect(user.admin).to be_truthy

      patch url, {admin: false}.to_json
      user = user_repo.active_user(1)
      expect(user.admin).to be_falsey
    end    
  end
end