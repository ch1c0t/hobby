require 'helper'

describe Hobby::Router do
  def env_for path, request_method = 'GET'
    {'REQUEST_METHOD' => request_method, 'PATH_INFO' => path }
  end

  subject { described_class.new }

  it 'works' do
    subject.add_route('GET', '/ololo') { 42 }

    route = subject.route_for env_for '/ololo'
    assert { route.call == 42 }

    route = subject.route_for env_for '/ololo2'
    assert { route.nil? }

    route = subject.route_for env_for '/ololo', 'POST'
    assert { route.nil? }
  end

  it 'with .' do
    subject.add_route('GET', '/route.json') { 42 }

    route = subject.route_for env_for '/route.json'
    assert { route.call == 42 }
  end

  it 'with -' do
    subject.add_route('GET', '/hello-world') { 42 }

    route = subject.route_for env_for '/hello-world'
    assert { route.call == 42 }
  end

  it 'with params' do
    subject
      .add_route 'GET', '/hello/:name' do :first end
      .add_route 'GET', '/say/:something/to/:someone' do :second end

    env = env_for '/hello/ololo'
    route = subject.route_for env
    assert { route.call == :first }
    assert { env[:path_params][:name] == 'ololo'}

    env = env_for '/say/nothing/to/no_one'
    route = subject.route_for env
    assert { route.call == :second }
    assert { env[:path_params][:something] == 'nothing'}
    assert { env[:path_params][:someone] == 'no_one'}
  end

  it 'with . and params' do
    subject.add_route('GET', '/route/:id.json') { 42 }

    env = env_for '/route/42.json'
    route = subject.route_for env
    assert { route.call == 42 }
    assert { env[:path_params][:id] == '42' }
  end

  it 'handle empty path as /' do
    subject.add_route 'GET' do :root end

    route = subject.route_for env_for ''
    assert { route.call == :root }
  end

  it 'memoizes the requests with params' do
    subject.add_route 'GET', '/hello/:name' do 'it memoizes' end
    subject.route_for env_for '/hello/ololo'

    assert { subject.instance_variable_get(:@routes).include? 'GET/hello/ololo' }
  end

  it do
    subject.add_route 'GET', '/hello' do 'it works' end

    route = subject.route_for env_for '/hello'
    assert {route.call == 'it works'}

    route = subject.route_for env_for '/hello/'
    assert {route.call == 'it works'}
  end

  it do
    env = env_for ''
    subject.route_for env
    
    assert { env.fetch(:path_params, {}).is_a? Hash }
  end
end
