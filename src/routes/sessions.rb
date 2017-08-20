namespace '/api' do  
  delete '/sessions' do
    @x_auth_header = env['HTTP_X_AUTHORIZATION']
    DB.db_delete_user_session(@x_auth_header)

    [200, json(result: "OK")]
  end
end