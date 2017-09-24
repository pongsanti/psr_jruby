describe 'Delete user truck' do
  include_context 'database'

  let(:url)       {'/api/user_trucks/1'}
  let(:mocktoken) {'mocktoken'}

  context 'in unauthenticated context' do
    it 'cannot delete user truck' do
      delete url

      expect(last_response.status).to eq(500)
      expect(last_response.body).to include('Unauthen')
    end
  end

  context 'in authenticated non-admin context' do
    before (:each) do
      create_user_session('normal_user@gmail.com', mocktoken)
      header 'X-Authorization', mocktoken
    end

    it 'cannot delete user truck' do
      delete url

      expect(last_response.status).to eq(500)
      expect(last_response.body).to include('not authorized')
    end
  end

  context 'in authenticated admin context' do
    id = 0
    before(:each) do
      create_admin_user_session('admin@gmail.com', mocktoken)
      header 'X-Authorization', mocktoken

      rom.gateways[:default].connection["INSERT INTO trucks (Truck_ID,Truck_Type_ID,Driver_ID,Location_ID,Truck_Status_ID,Overall_Weight,Axles,Wheels,Picture,License_Plate,License_Expiry,Insurance_Expiry,Brand,Color,Product_Year,Note,CREATED_DATE,CREATED_USER,CREATED_HOST,UPDATED_DATE,UPDATED_USER,UPDATED_HOST,IsActive,Owner) VALUES (1,2,-1,2,1,2000.00,2,4,'20150825101111_81-0129.jpg','81-0129','2014-12-31 00:00:00.000','2015-03-26 00:00:00.000','Isuzu','ฟ้า','1996-01-01 00:00:00.000','',NULL,NULL,NULL,'2016-05-04 12:53:53.000',NULL,'PSR-SERVER-31',1,1)"].insert
      id = rom.gateways[:default].connection["insert into user_trucks (user_id, truck_id, start_at, end_at) values (1, 1, current_timestamp, current_timestamp)"].insert
    end

    it 'rejects if user_truck_id not digit' do
      delete '/api/user_trucks/abc'

      expect(last_response.status).to eq(500)
      expect(last_response.body).to include('must be', 'integer')
    end

    it 'rejects if user truck not existed' do
      delete '/api/user_trucks/9999'

      expect(last_response.status).to eq(500)
      expect(last_response.body).to include('User truck not existed')
    end

    it 'can delete user truck' do
      delete "/api/user_trucks/#{id}"

      expect(last_response.status).to eq(200)
      expect(last_response.body).to include('OK')

      expect(user_truck_repo.active_by_id(id).one).to be_nil
    end
  end
  
end