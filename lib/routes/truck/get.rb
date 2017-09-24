namespace '/api' do
  get '/trucks' do
    authorize_admin? env
    
    dataset = @truck_repo.all
    
    [200, json(trucks: dataset.to_a)]
  end
end
