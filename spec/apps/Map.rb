map '/map', Proc.new { |env| [200, {}, ['from map']] }
map '/deprecated_map' do
  run Proc.new { |env| [200, {}, ['from deprecated map']] }
end
get('/') { 'hello world' }
