namespace '/api' do
  get '/locations' do
    authorize? env
    
    @tblhistory_repo.location_by_truck(1).to_a

    [200, json(user: @user.display_name)]
  end
end
