require_relative 'helper'

module Minitest
  class Test
    include Rack::Test::Methods

    def mock_app(&block)
      @app = Class.new(Hobby::App, &block).new
    end

    def app
      @app
    end
  end
end

describe Hobby::App do
  describe :main_app do
    before do
      mock_app do
        Hobby::Verbs.each do |verb|
          class_eval "#{verb.downcase}('/') { '#{verb}' }"
          class_eval "#{verb.downcase}('/route.json') { '#{verb} /route.json' }"
          class_eval "#{verb.downcase}('/route/:id.json') { request.params[:id] }"
          class_eval "#{verb.downcase}('/:name') { request.params[:name] }"
        end
      end
    end

    Hobby::Verbs.each do |verb|
      describe 'when the request matches a route' do
        it "matches #{verb} ''" do
          send verb.downcase, ''
          assert last_response.ok?
          assert_equal verb, last_response.body
        end

        it 'matches #{verb} /' do
          send verb.downcase, '/'
          assert last_response.ok?
          assert_equal verb, last_response.body
        end

        it 'matches #{verb} /route.json' do
          send verb.downcase, '/route.json'
          assert last_response.ok?
          assert_equal "#{verb} /route.json", last_response.body
        end

        it 'matches #{verb} /route/:id.json' do
          send verb.downcase, '/route/1.json'
          assert last_response.ok?
          assert_equal '1', last_response.body
        end

        it 'matches #{verb} /:name' do
          send verb.downcase, '/hobbit'
          assert last_response.ok?
          assert_equal 'hobbit', last_response.body

          send verb.downcase, '/hello-hobbit'
          assert last_response.ok?
          assert_equal 'hello-hobbit', last_response.body
        end
      end

      describe 'when the request not matches a route' do
        it 'responds with 404 status code' do
          send verb.downcase, '/not/found'
          assert last_response.not_found?
          assert_equal '', last_response.body
        end
      end
    end
  end

  describe :map_app do
    before do
      mock_app do
        map '/map' do
          run Proc.new { |env| [200, {}, ['from map']] }
        end

        get('/') { 'hello world' }
      end
    end

    it 'mounts an application to the rack stack' do
      get '/map'
      assert_equal 'from map', last_response.body
    end
  end

  describe :use_app do
    before do
      mock_app do
        middleware = Class.new do
          def initialize(app = nil)
            @app = app
          end

          def call(env)
            request = Rack::Request.new(env)
            @app.call(env) unless request.path_info == '/use'
            [200, {}, 'from use']
          end
        end

        use middleware

        get('/') { 'hello world' }
      end
    end

    it 'adds a middleware to the rack stack' do
      get '/use'
      assert_equal 'from use', last_response.body
    end
  end

  describe :halt_app do
    before do
      mock_app do
        get '/halt' do
          response.status = 501
        end

        get '/halt_finished' do
          response.status = 404
          'Not found'
        end
      end
    end

    it 'halts the execution with a response' do
      get '/halt'
      assert { last_response.status == 501 }
    end

    it 'halts the execution with a finished response' do
      get '/halt_finished'
      assert { last_response.status == 404 }
    end
  end

  describe :router_app do
    before do
      mock_app do
        const_set :Router, Class.new {
          def add_route(*)
          end

          def route_for _request
            Proc.new { 'for any route' }
          end
        }.new
      end
    end

    it 'returns for any route' do
      get '/'
      assert { last_response.body == 'for any route' }

      get '/some-other-route'
      assert { last_response.body == 'for any route' }
    end
  end

  describe :custom_members do
    before do
      mock_app do
        const_set :Builder, Rack::Builder.new
        Request = Rack::Request
        Response = Rack::Response

        get '/' do
          'it works'
        end
      end
    end

    it 'works' do
      get '/'
      assert { last_response.body == 'it works' }
    end
  end

  describe :without_path do
    before do
      mock_app do
        get do
          'root'
        end
      end
    end

    it 'is accessible as /' do
      get '/'
      assert { last_response.body == 'root' }
    end
  end
end
