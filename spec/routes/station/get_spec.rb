describe 'Get stations' do
  include_context 'database'

  let(:url)       {'/api/stations'}
  let(:mocktoken) {'mocktoken'}

  context 'in unauthenticated context' do
    it 'cannot get stations list' do
      get url

      expect(last_response.status).to eq(500)
      expect(last_response.body).to include('Unauthen')
    end
  end

  context 'in authenticated non-admin context' do
    before (:each) do
      create_user_session('normal_user@gmail.com', mocktoken)
      header 'X-Authorization', mocktoken
    end

    it 'cannot get stations list' do
      get url

      expect(last_response.status).to eq(500)
      expect(last_response.body).to include('not authorized')
    end
  end

  context 'in authenticated admin context' do
    before(:each) do
      create_admin_user_session('admin@gmail.com', mocktoken)
      header 'X-Authorization', mocktoken
    end

    it 'can get stations list' do
      get url

      expect(last_response.status).to eq(200)
      expect(last_response.body).to include('stations', 'id', 'name')
    end
  end
  
end