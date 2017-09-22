describe 'Patch user stations' do
  include_context 'database'

  let(:url)       {'/api/user_stations/1'}
  let(:mocktoken) {'mocktoken'}
  let(:req_obj)   { {stations: [1, 2, 3]} }

  context 'in unauthenticated context' do
    it 'cannot patch user stations list' do
      patch url, req_obj.to_json

      expect(last_response.status).to eq(500)
      expect(last_response.body).to include('Unauthen')
    end
  end

  context 'in authenticated non-admin context' do
    before (:each) do
      create_user_session('normal_user@gmail.com', mocktoken)
      header 'X-Authorization', mocktoken
    end

    it 'cannot patch user stations list' do
      patch url, req_obj.to_json

      expect(last_response.status).to eq(500)
      expect(last_response.body).to include('not authorized')
    end
  end

  context 'in authenticated admin context' do
    before(:each) do
      create_admin_user_session('admin@gmail.com', mocktoken)
      header 'X-Authorization', mocktoken
    end

    it 'rejects if user id not digit' do
      patch '/api/user_stations/abc'

      expect(last_response.status).to eq(500)
      expect(last_response.body).to include('must be', 'integer')
    end

    it 'rejects if station ids is missing' do
      patch url, {}.to_json

      expect(last_response.status).to eq(500)
      expect(last_response.body).to include('stations', 'missing')
    end

    it 'rejects if station ids is not array' do
      patch url, req_obj.merge(stations: 'abc').to_json

      expect(last_response.status).to eq(500)
      expect(last_response.body).to include('stations', 'array')
    end    

    it 'rejects if user id not existed' do
      patch '/api/user_stations/9999', req_obj.to_json

      expect(last_response.status).to eq(500)
      expect(last_response.body).to include('User not existed')
    end

    it 'can patch user stations list' do
      patch url, req_obj.to_json

      expect(last_response.status).to eq(200)
      expect(last_response.body).to include('stations', 'id', 'name')
    end
  end
  
end