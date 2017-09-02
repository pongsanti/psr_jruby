describe 'Delete sessions' do
  include_context 'database'

  let(:email)     { 'john@gmail.com' }
  let(:password)  { '1234' }
  let(:request)   { {email: email, password: password}.to_json }

  context 'in authenticated context' do
    it 'can delete session' do
      token = 'mocktoken'
      # prepare
      create_user_session(email, token)
      
      header 'X-Authorization', token
      delete '/api/sessions'

      expect(last_response.status).to eq(200)
      expect(session_repo.find_by_token(token)).to be_nil
    end
  end
  
end