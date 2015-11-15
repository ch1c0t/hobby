get '/halt' do
  response.status = 501
end

get '/halt_finished' do
  response.status = 404
  'Not found'
end
