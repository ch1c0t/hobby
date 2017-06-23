require 'helper'
require 'router_matchers'

describe Hobby::Router do
  include RouterMatchers

  routes = %w!
    /with.dot
    /with-hyphen
    /hello/:name
    /say/:something/to/:someone
    /route/:id.json
    /existent/only/for/GET
    /js/:name.js
    /dot/:first.:second
  !

  before { add_routes *routes }

  it { should find_route '/with.dot' }
  it { should find_route '/with-hyphen' }
  it { should find_route '/with.dot/' }
  it { should find_route '/with-hyphen/' }

  it { should find_route '/existent/only/for/GET' }
  it { should_not find_route '/nonexistent' }
  it { should_not find_route '/existent/only/for/GET', 'POST' }

  it { should find_route('/hello/ololo').and_set_params(name: 'ololo') }
  it { should find_route('/route/66.json').and_set_params(id: '66') }
  it do
    should find_route('/say/nothing/to/no_one').
           and_set_params(something: 'nothing', someone: 'no_one')
  end

  it { should find_route('/js/with-js.js').and_set_params(name: 'with-js') }
  it do
    should find_route('/dot/aa.wtf').
           and_set_params(first: 'aa', second: 'wtf')
  end


  it 'memoizes requests with params' do
    subject.route_for env_for '/hello/ololo'

    assert { subject.instance_variable_get(:@routes).include? 'GET/hello/ololo' }
  end

  it 'dups a route for each request' do
    router = described_class.new
    route = router.add_route 'GET', '/some_path' do :some_action end

    duped_route = router.route_for env_for '/some_path'

    assert { not route.equal? duped_route }
  end
end
