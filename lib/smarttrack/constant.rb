module SmartTrack::Constant
  CORS_HASH = {
    'Access-Control-Allow-Origin' => '*',
    'Access-Control-Allow-Methods' => 'HEAD,GET,PUT,POST,DELETE,OPTIONS',
    'Access-Control-Allow-Headers' => 'X-Authorization, Content-Type' }

  ONE_MONTH_IN_MS = (60*60*24*30)
  PASSWORD_MIN_SIZE = 8
end