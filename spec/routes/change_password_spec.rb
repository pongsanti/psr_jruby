describe 'Post change password' do
  include_context 'database'

  let(:mocktoken) {'mocktoken'}
  let(:json_req) {
    {old_password: 'xxx',
    new_password: '1234_abcd'}.to_json
  }

  context 'in unauthenticated context' do
    it 'cannot change password' do

      header 'X-Authorization', 'not_valid_token'
      post_with_json '/api/change_password', json_req

      expect(last_response.status).to eq(500)
    end
  end

  context 'in authenticated context' do
    it 'can change password' do
      create_user_session('admin@gmail.com', mocktoken)

      header 'X-Authorization', mocktoken
      post_with_json '/api/change_password', json_req

      expect(last_response.status).to eq(200)
      expect(last_response.body).to include('updated')
    end
  end
  
end