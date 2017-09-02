describe 'Authenticated route' do
  include_context 'database'

  let(:mocktoken)   {'mocktoken'}
  let(:email)       {'admin@gmail.com'}
  let(:json_req)    {
    { old_password: 'xxx', new_password: '12345678' }.to_json
  }

  context 'in authenticated context' do
    it 'works normally if token has not expired' do
      # prepare
      create_user_session(email, mocktoken)

      header 'X-Authorization', mocktoken
      post_with_json '/api/change_password', json_req

      expect(last_response.status).to eq(200)
      expect(last_response.body).to include('updated')
    end

    it 'reject request if token has expired' do
      # prepare
      create_user_session(email, mocktoken)
      user_session = session_repo.find_by_token(mocktoken)
      session_repo.update(user_session.id, expired_at: Time.now - SmartTrack::Constant::ONE_MONTH_IN_MS)

      header 'X-Authorization', mocktoken
      post_with_json '/api/change_password', json_req

      expect(last_response.status).to eq(500)
      expect(last_response.body).to include('expired')
    end
  end
  
end