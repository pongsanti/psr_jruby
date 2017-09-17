describe 'Post change password' do
  include_context 'database'

  let(:mocktoken)   {'mocktoken'}
  let(:email)       {'admin@gmail.com'}
  let(:new_password) {'1234_abcd'}
  let(:req_obj)     {
    { old_password: 'xxx',
      new_password: new_password}
    }
  let(:json_req)    { req_obj.to_json }

  context 'in unauthenticated context' do
    it 'cannot change password' do

      header 'X-Authorization', 'not_valid_token'
      post_with_json '/api/change_password', json_req

      expect(last_response.status).to eq(500)
    end
  end

  context 'in authenticated context' do
    before(:each) do
      create_user_session(email, mocktoken)
      header 'X-Authorization', mocktoken
    end
    
    it 'rejects if the old password not presence' do
      req_obj.delete(:old_password)
      post_with_json '/api/change_password', req_obj.to_json

      expect(last_response.status).to eq(500)
      expect(last_response.body).to include('old_password', 'missing')
    end

    it 'rejects if the old password not matched' do
      post_with_json '/api/change_password',
        req_obj.merge(old_password: 'yyy').to_json

      expect(last_response.status).to eq(500)
      expect(last_response.body).to include('password', 'incorrect')
    end

    it 'rejects if the new password too short' do
      post_with_json '/api/change_password',
        req_obj.merge(new_password: '1234').to_json

      expect(last_response.status).to eq(500)
      expect(last_response.body).to include('new_password', 'size', 'less than')
    end

    it 'can change password' do
      post_with_json '/api/change_password', json_req

      expect(last_response.status).to eq(200)
      expect(last_response.body).to include('updated')

      # check new password in database
      user = user_repo.find_by_email(email)
      expect(BCrypt::Password.new(user.password)).to eq(new_password)
    end
  end
  
end