namespace '/api' do  
  delete '/sessions' do
    token = env['HTTP_X_AUTHORIZATION']
    session = @session_repo.find_by_token(token)
    @session_repo.delete(session.id) if session

    [200, json(result: "OK")]
  end
end