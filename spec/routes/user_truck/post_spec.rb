describe 'Post user truck' do
  include_context 'database'

  let(:url)       {'/api/user_trucks/1'}
  let(:mocktoken) {'mocktoken'}
  let(:req_obj)   {
    { truck_id: 1,
      start_at: '2017-09-24 06:00:00',
      end_at: '2017-09-24 21:00:00'
    }
  }

  context 'in unauthenticated context' do
    it 'cannot post user truck' do
      post url, req_obj.to_json

      expect(last_response.status).to eq(500)
      expect(last_response.body).to include('Unauthen')
    end
  end

  context 'in authenticated non-admin context' do
    before (:each) do
      create_user_session('normal_user@gmail.com', mocktoken)
      header 'X-Authorization', mocktoken
    end

    it 'cannot post user truck' do
      post url, req_obj.to_json

      expect(last_response.status).to eq(500)
      expect(last_response.body).to include('not authorized')
    end
  end

  context 'in authenticated admin context' do
    before(:each) do
      create_admin_user_session('admin@gmail.com', mocktoken)
      header 'X-Authorization', mocktoken

      rom.gateways[:default].connection["INSERT INTO trucks (Truck_ID,Truck_Type_ID,Driver_ID,Location_ID,Truck_Status_ID,Overall_Weight,Axles,Wheels,Picture,License_Plate,License_Expiry,Insurance_Expiry,Brand,Color,Product_Year,Note,CREATED_DATE,CREATED_USER,CREATED_HOST,UPDATED_DATE,UPDATED_USER,UPDATED_HOST,IsActive,Owner) VALUES (1,2,-1,2,1,2000.00,2,4,'20150825101111_81-0129.jpg','81-0129','2014-12-31 00:00:00.000','2015-03-26 00:00:00.000','Isuzu','ฟ้า','1996-01-01 00:00:00.000','',NULL,NULL,NULL,'2016-05-04 12:53:53.000',NULL,'PSR-SERVER-31',1,1)"].insert      
    end

    it 'rejects if user id not digit' do
      post '/api/user_trucks/abc'

      expect(last_response.status).to eq(500)
      expect(last_response.body).to include('must be', 'integer')
    end

    it 'rejects if truck id is missing' do
      req_obj.delete(:truck_id)
      post url, req_obj.to_json

      expect(last_response.status).to eq(500)
      expect(last_response.body).to include('truck_id', 'missing')
    end

    it 'rejects if start_at is missing' do
      req_obj.delete(:start_at)
      post url, req_obj.to_json

      expect(last_response.status).to eq(500)
      expect(last_response.body).to include('start_at', 'missing')
    end

    it 'rejects if end_at is missing' do
      req_obj.delete(:end_at)
      post url, req_obj.to_json

      expect(last_response.status).to eq(500)
      expect(last_response.body).to include('end_at', 'missing')
    end

    it 'rejects if start_at is not datetime' do
      req_obj[:start_at] = 'xxxooo'
      post url, req_obj.to_json

      expect(last_response.status).to eq(500)
      expect(last_response.body).to include('start_at', 'date time')
    end

    it 'rejects if end_at is not datetime' do
      req_obj[:end_at] = 'xxxooo'
      post url, req_obj.to_json

      expect(last_response.status).to eq(500)
      expect(last_response.body).to include('end_at', 'date time')
    end    

    it 'rejects if user id not existed' do
      post '/api/user_trucks/9999', req_obj.to_json

      expect(last_response.status).to eq(500)
      expect(last_response.body).to include('User not existed')
    end

    it 'can post user truck' do
      expect(truck_repo.by_user(1).to_a.size).to eq(0)

      post url, req_obj.to_json

      expect(last_response.status).to eq(201)
      expect(last_response.body).to include('OK')

      trucks = truck_repo.by_user(1).to_a
      expect(trucks.size).to eq(1)
    end
  end
  
end