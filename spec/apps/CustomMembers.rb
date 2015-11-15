Builder = Rack::Builder.new
Request = Rack::Request
Response = Rack::Response

get '/' do
  'it works'
end
