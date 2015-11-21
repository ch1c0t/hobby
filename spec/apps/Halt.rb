get '/halt' do
  response.status = 501
end

get '/halt_finished' do
  response.status = 404
  'Not found'
end

get '/increment_instance_variable' do
  @instance_variable ||= 0
  @instance_variable += 1
  @instance_variable.to_s
end
