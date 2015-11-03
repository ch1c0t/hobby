require_relative 'helper'

def request_to path, request_method: 'GET'
  Hobby::Request.new Rack::MockRequest.env_for "http://example.com:8080/#{path}", method: request_method
end

describe Hobby::Router do
  before do
    @router = Hobby::Router.new
    @route = -> { :wrapped }
  end

  it 'works' do
    @router.add_route 'GET', '/ololo', &@route

    route = @router.route_for request_to 'ololo'
    assert { route.to_proc.call == :wrapped }

    route = @router.route_for request_to 'ololo2'
    assert { route.nil? }

    route = @router.route_for request_to 'ololo', request_method: 'POST'
    assert { route.nil? }
  end

  it 'with .' do
    @router.add_route 'GET', '/route.json', &@route

    route = @router.route_for request_to 'route.json'
    assert { route.to_proc.call == :wrapped }
  end

  it 'with -' do
    @router.add_route 'GET', '/hello-world', &@route

    route = @router.route_for request_to 'hello-world'
    assert { route.to_proc.call == :wrapped }
  end

  it 'with params' do
    @router
      .add_route 'GET', '/hello/:name' do :first end
      .add_route 'GET', '/say/:something/to/:someone' do :second end

    request = request_to 'hello/ololo'
    route = @router.route_for request
    assert { route.to_proc.call == :first }
    assert { request.params[:name] == 'ololo'}

    request = request_to 'say/nothing/to/no_one'
    route = @router.route_for request
    assert { route.to_proc.call == :second }
    assert { request.params[:something] == 'nothing'}
    assert { request.params[:someone] == 'no_one'}
  end

  it 'with . and params' do
    @router.add_route 'GET', '/route/:id.json', &@route

    request = request_to 'route/42.json'
    route = @router.route_for request
    assert { route.to_proc.call == :wrapped }
    assert { request.params[:id] == '42' }
  end

  it 'handle empty path as /' do
    @router.add_route 'GET' do :root end

    env = { 'REQUEST_METHOD' => 'GET', 'PATH_INFO' => '' }
    request = Hobby::Request.new env
    route = @router.route_for request
    assert { route.call == :root }
  end
end
