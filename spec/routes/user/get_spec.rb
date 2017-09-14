describe 'Get users' do
  include_context 'database'

  let(:mocktoken) {'mocktoken'}

  context 'in unauthenticated context' do
    it 'cannot get users list' do
      get '/api/users'

      expect(last_response.status).to eq(500)
      expect(last_response.body).to include('Unauthen')
    end
  end

  context 'in authenticated context' do
    before(:each) do
      create_user_session('admin@gmail.com', mocktoken)
      header 'X-Authorization', mocktoken
    end

    it 'receives page param' do
      get '/api/users?page=1'
      expect(last_response.status).to eq(200)
    end

    it 'receives size param' do
      get '/api/users?size=10'
      expect(last_response.status).to eq(200)
    end

    it 'receives order param' do
      get '/api/users?order=email'
      expect(last_response.status).to eq(200)
    end

    it 'receives direction param' do
      get '/api/users?direction=desc'
      expect(last_response.status).to eq(200)
    end

    it 'rejects if page param is not integer' do
      get '/api/users?page=a'
      expect(last_response.status).to eq(500)
      expect(last_response.body).to include('errors')
    end

    it 'rejects if size param is not integer' do
      get '/api/users?size=a'
      expect(last_response.status).to eq(500)
      expect(last_response.body).to include('errors')
    end

    it 'rejects if order param are digits' do
      get '/api/users?order=123'
      expect(last_response.status).to eq(500)
      expect(last_response.body).to include('errors')
    end

    it 'rejects if direction param is invalid' do
      get '/api/users?direction=xxx'
      expect(last_response.status).to eq(500)
      expect(last_response.body).to include('errors')
    end

    it 'can get users list' do
      get '/api/users'

      expect(last_response.status).to eq(200)
      expect(last_response.body).to include('users',
        'pager', 'next_page', 'prev_page', 'total', 'total_pages',
        'current_page', 'limit_value')
    end
  end
  
end