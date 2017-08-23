module SmartTrack::Test
  module ControllerHelper
    def post_with_json(uri, json)
      # No assertion in this, we just demonstrate how you can post a JSON-encoded string.
      # By default, Rack::Test will use HTTP form encoding if you pass in a Hash as the
      # parameters, so make sure that `json` below is already a JSON-serialized string.
      post(uri, json, { 'CONTENT_TYPE' => 'application/json' })
    end
  end
end