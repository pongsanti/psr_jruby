namespace '/api' do
  get '/stations' do
    authorize_admin? env
    
    dataset = @station_repo.all
    
    [200, json(stations: dataset.to_a)]
  end
end
