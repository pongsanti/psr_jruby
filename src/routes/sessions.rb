namespace '/api' do  
  delete '/sessions' do
    logger.info @x_auth_header
    db_delete_user_session(@x_auth_header)

    [200, json(result: "OK")]
  end
end