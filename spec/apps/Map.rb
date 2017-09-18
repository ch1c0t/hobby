map '/map', to: Proc.new { |env| [200, {}, ['from map']] }
get('/') { 'hello world' }
