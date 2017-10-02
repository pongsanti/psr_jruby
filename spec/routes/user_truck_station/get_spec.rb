describe 'Get user truck stations' do
  include_context 'database'

  let(:url)       {'/api/user_truck_stations/user_truck/1'}
  let(:mocktoken) {'mocktoken'}

  context 'in unauthenticated context' do
    it 'cannot get user truck stations list' do
      get url

      expect(last_response.status).to eq(500)
      expect(last_response.body).to include('Unauthen')
    end
  end

  context 'in authenticated non-admin context' do
    ut_id = 0;
    before (:each) do
      create_user_session('normal_user@gmail.com', mocktoken)
      header 'X-Authorization', mocktoken

      truck_id = rom.gateways[:default].connection["INSERT INTO trucks (Truck_ID,Truck_Type_ID,Driver_ID,Location_ID,Truck_Status_ID,Overall_Weight,Axles,Wheels,Picture,License_Plate,License_Expiry,Insurance_Expiry,Brand,Color,Product_Year,Note,CREATED_DATE,CREATED_USER,CREATED_HOST,UPDATED_DATE,UPDATED_USER,UPDATED_HOST,IsActive,Owner) VALUES (1,2,-1,2,1,2000.00,2,4,'20150825101111_81-0129.jpg','81-0129','2014-12-31 00:00:00.000','2015-03-26 00:00:00.000','Isuzu','ฟ้า','1996-01-01 00:00:00.000','',NULL,NULL,NULL,'2016-05-04 12:53:53.000',NULL,'PSR-SERVER-31',1,1)"].insert
      ut_id = rom.gateways[:default].connection["insert into user_trucks (user_id, truck_id, start_at, end_at) values (1, #{truck_id},
        current_timestamp - INTERVAL 1 DAY,
        current_timestamp + INTERVAL 1 DAY)"].insert
      rom.gateways[:default].connection["insert into user_truck_stations (user_truck_id, station_id, arrived_at, departed_at) values (#{ut_id}, 1, now(), now())"].insert           
    end

    it 'can get user truck stations list' do
      get "/api/user_truck_stations/user_truck/#{ut_id}"

      expect(last_response.status).to eq(200)
            expect(last_response.body).to include('uts',
        'station_name', 'arrived_at', 'departed_at')
    end
  end

end