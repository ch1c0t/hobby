get '/query_string' do
  env['QUERY_STRING']
end

get '/access_params' do
  request.params['key']
end

get '/access_path_params_via_my' do
  my[:key].nil?
end

get '/access_path_params_via_env' do
  env[:path_params].nil?
end
