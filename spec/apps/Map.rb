map '/map' do
  run Proc.new { |env| [200, {}, ['from map']] }
end

get('/') { 'hello world' }
