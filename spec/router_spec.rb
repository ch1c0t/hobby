require 'helper'

describe Hobby::Router, type: :router do
  routes = %w!
    /with.dot
    /with-hyphen
    /hello/:name
    /say/:something/to/:someone
    /route/:id.json
    /existent/only/for/GET
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


  it 'handles empty path as /' do
    subject.add_route 'GET' do :root end
    route = subject.route_for env_for ''

    assert { route.call == :root }
  end

  it 'memoizes requests with params' do
    subject.route_for env_for '/hello/ololo'

    assert { subject.instance_variable_get(:@routes).include? 'GET/hello/ololo' }
  end

  it 'does not touch path params when there is nothing to set'do
    env = env_for ''
    subject.route_for env
    
    assert { env.fetch(:path_params, {}).is_a? Hash }
  end

  it 'sets path params when needed' do
    env = env_for '/hello/ololo'
    subject.route_for env

    assert { env[:path_params].is_a? Hash }
  end
end
