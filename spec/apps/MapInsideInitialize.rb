first_app = Proc.new { |env| [200, {}, ['first mapapp']] }
second_app = Proc.new { |env| [200, {}, ['second mapapp']] }

map '/first_map', to: first_app
map '/second_map', to: second_app

get('/') { 'hello world' }

def initialize hash = {}
  hash.each do |route, app|
    map route, to: app
  end
end
