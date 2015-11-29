require 'helper'

describe Hobby::Router do
  def request_to path, request_method: 'GET'
    Hobby::Request.new Rack::MockRequest.env_for "http://example.com:8080/#{path}", method: request_method
  end

  subject { described_class.new }

  it 'works' do
    subject.add_route('GET', '/ololo') { 42 }

    route = subject.route_for request_to 'ololo'
    assert { route.to_proc.call == 42 }

    route = subject.route_for request_to 'ololo2'
    assert { route.nil? }

    route = subject.route_for request_to 'ololo', request_method: 'POST'
    assert { route.nil? }
  end

  it 'with .' do
    subject.add_route('GET', '/route.json') { 42 }

    route = subject.route_for request_to 'route.json'
    assert { route.to_proc.call == 42 }
  end

  it 'with -' do
    subject.add_route('GET', '/hello-world') { 42 }

    route = subject.route_for request_to 'hello-world'
    assert { route.to_proc.call == 42 }
  end

  it 'with params' do
    subject
      .add_route 'GET', '/hello/:name' do :first end
      .add_route 'GET', '/say/:something/to/:someone' do :second end

    request = request_to 'hello/ololo'
    route = subject.route_for request
    assert { route.to_proc.call == :first }
    assert { request.params[:name] == 'ololo'}

    request = request_to 'say/nothing/to/no_one'
    route = subject.route_for request
    assert { route.to_proc.call == :second }
    assert { request.params[:something] == 'nothing'}
    assert { request.params[:someone] == 'no_one'}
  end

  it 'with . and params' do
    subject.add_route('GET', '/route/:id.json') { 42 }

    request = request_to 'route/42.json'
    route = subject.route_for request
    assert { route.to_proc.call == 42 }
    assert { request.params[:id] == '42' }
  end

  it 'handle empty path as /' do
    subject.add_route 'GET' do :root end

    env = { 'REQUEST_METHOD' => 'GET', 'PATH_INFO' => '' }
    request = Hobby::Request.new env
    route = subject.route_for request
    assert { route.call == :root }
  end

  it 'memoizes the requests with params' do
    subject.add_route 'GET', '/hello/:name' do 'it memoizes' end
    subject.route_for request_to 'hello/ololo'

    assert { subject.instance_variable_get(:@routes).include? 'GET/hello/ololo' }
  end

  it do
    subject.add_route 'GET', '/hello' do 'it works' end

    request = Hobby::Request.new({'REQUEST_METHOD' => 'GET', 'PATH_INFO' => '/hello' })
    route = subject.route_for request
    assert {route.call == 'it works'}

    request = Hobby::Request.new({'REQUEST_METHOD' => 'GET', 'PATH_INFO' => '/hello/' })
    route = subject.route_for request
    assert {route.call == 'it works'}
  end
end
