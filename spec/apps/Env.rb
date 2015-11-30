get '/ping' do
  env['QUERY_STRING']
end

get '/for_request' do
  request.params['key']
end

get '/for_my' do
  my[:key].nil?
end

get '/for_direct_path_params' do
  env[:path_params].nil?
end
