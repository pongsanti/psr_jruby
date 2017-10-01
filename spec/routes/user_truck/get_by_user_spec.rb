describe 'Get user trucks' do
  include_context 'database'

  let(:url)       {'/api/user_trucks/user/1'}
  let(:mocktoken) {'mocktoken'}

  context 'in unauthenticated context' do
    it 'cannot get user trucks list' do
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

    it 'cannot get user trucks list' do
      get url

      expect(last_response.status).to eq(500)
      expect(last_response.body).to include('not authorized')
    end
  end

  context 'in authenticated admin context' do
    before(:each) do
      create_admin_user_session('admin@gmail.com', mocktoken)
      header 'X-Authorization', mocktoken

      rom.gateways[:default].connection["INSERT INTO trucks (Truck_ID,Truck_Type_ID,Driver_ID,Location_ID,Truck_Status_ID,Overall_Weight,Axles,Wheels,Picture,License_Plate,License_Expiry,Insurance_Expiry,Brand,Color,Product_Year,Note,CREATED_DATE,CREATED_USER,CREATED_HOST,UPDATED_DATE,UPDATED_USER,UPDATED_HOST,IsActive,Owner) VALUES (1,2,-1,2,1,2000.00,2,4,'20150825101111_81-0129.jpg','81-0129','2014-12-31 00:00:00.000','2015-03-26 00:00:00.000','Isuzu','ฟ้า','1996-01-01 00:00:00.000','',NULL,NULL,NULL,'2016-05-04 12:53:53.000',NULL,'PSR-SERVER-31',1,1)"].insert
      # this record will be returned
      rom.gateways[:default].connection["insert into user_trucks (user_id, truck_id, start_at, end_at) values (1, 1,
        current_timestamp - INTERVAL 1 DAY,
        current_timestamp + INTERVAL 1 DAY)"].insert
      # filter out because deleted
      rom.gateways[:default].connection["insert into user_trucks (user_id, truck_id, start_at, end_at, deleted_at) values (1, 1, current_timestamp, current_timestamp, current_timestamp)"].insert
      # filter out because start_at, end_at
      rom.gateways[:default].connection["insert into user_trucks (user_id, truck_id, start_at, end_at) values (1, 1,
        current_timestamp - INTERVAL 12 DAY,
        current_timestamp - INTERVAL 11 DAY)"].insert      
    end

    it 'rejects if user id is not digit' do
      get '/api/user_trucks/user/abc'

      expect(last_response.status).to eq(500)
      expect(last_response.body).to include('integer')
    end

    it 'rejects if user id is not existed' do
      get '/api/user_trucks/user/9999'

      expect(last_response.status).to eq(500)
      expect(last_response.body).to include('not existed')
    end    

    it 'can get user trucks list' do
      get url

      expect(last_response.status).to eq(200)
      expect(last_response.body).to include('trucks',
        'id', 'license_plate', 'brand', 'color',
        'user_truck_id', 'start_at', 'end_at')

      trucks = truck_repo.by_user(1).to_a
      expect(trucks.size).to eq(1)
    end
  end
  
end