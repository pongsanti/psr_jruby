describe 'Get locations' do
  include_context 'database'

  let(:url)       {'/api/locations'}
  let(:mocktoken) {'mocktoken'}

  context 'in unauthenticated context' do
    it 'cannot get locations list' do
      get url

      expect(last_response.status).to eq(500)
      expect(last_response.body).to include('Unauthen')
    end
  end

  context 'in authenticated non-admin context' do
    before (:each) do
      user = create_user_session('normal_user@gmail.com', mocktoken)
      header 'X-Authorization', mocktoken
      
      rom.gateways[:default].connection["INSERT INTO trucks (Truck_ID,Truck_Type_ID,Driver_ID,Location_ID,Truck_Status_ID,Overall_Weight,Axles,Wheels,Picture,License_Plate,License_Expiry,Insurance_Expiry,Brand,Color,Product_Year,Note,CREATED_DATE,CREATED_USER,CREATED_HOST,UPDATED_DATE,UPDATED_USER,UPDATED_HOST,IsActive,Owner) VALUES (2,5,172,2,1,8080.00,3,10,'20150914144818_70-6707.jpg','70-6707','2014-12-31 00:00:00.000','2015-07-24 00:00:00.000','Nissan','เทา','2002-01-01 00:00:00.000','',NULL,NULL,NULL,'2016-09-17 14:46:33.000',NULL,'PSR-SERVER-31',1,1)"].insert
      # this record will be returned
      rom.gateways[:default].connection["insert into user_trucks (user_id, truck_id, start_at, end_at) values (#{user.id}, 2,
        current_timestamp - INTERVAL 1 DAY,
        current_timestamp + INTERVAL 1 DAY)"].insert
    end

    it 'can get locations list' do
      get url

      expect(last_response.status).to eq(200)
      expect(last_response.body).to include('locations',
        'user_truck_id', 'license_plate', 'brand', 'color',
        'serial_sim',
        'datetime', 'latitude', 'longitude')
    end
  end
  
end