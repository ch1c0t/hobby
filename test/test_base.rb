require_relative 'minitest_helper'

scope Hobbit::Base do
  before do
    mock_app do
      %w(DELETE GET HEAD OPTIONS PATCH POST PUT).each do |verb|
        class_eval "#{verb.downcase}('/') { '#{verb}' }"
        class_eval "#{verb.downcase}('/route.json') { '#{verb} /route.json' }"
        class_eval "#{verb.downcase}('/route/:id.json') { request.params[:id] }"
        class_eval "#{verb.downcase}('/:name') { request.params[:name] }"
      end
    end
  end

  scope '::map' do
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

  scope '::new' do
    it 'returns an instance of Rack::Builder' do
      assert_kind_of Rack::Builder, app
    end
  end

  scope '::call' do
    it 'creates a new instance and sends the call message' do
      a = Class.new(Hobbit::Base) do
        get '/' do
          'hello world'
        end
      end

      env = { 'PATH_INFO' => '/', 'REQUEST_METHOD' => 'GET' }
      status, headers, body_proxy = a.call env
      hobbit_response = body_proxy.instance_variable_get(:@body)
      assert_equal ['hello world'], hobbit_response.instance_variable_get(:@body)
    end
  end

  scope '::stack' do
    it 'returns an instance of Rack::Builder' do
      assert_kind_of Rack::Builder, app.to_app.class.stack
    end
  end

  scope '::use' do
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

  scope '#call' do
    %w(DELETE GET HEAD OPTIONS PATCH POST PUT).each do |verb|
      scope 'when the request matches a route' do
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

      scope 'when the request not matches a route' do
        it 'responds with 404 status code' do
          send verb.downcase, '/not/found'
          assert last_response.not_found?
          assert_equal '', last_response.body
        end
      end
    end
  end

  scope '#halt' do
    before do
      mock_app do
        get '/halt' do
          response.status = 501
          halt response.finish
        end

        get '/halt_finished' do
          halt [404, {}, ['Not found']]
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

  it 'responds to call' do
    assert app.to_app.respond_to? :call
  end
end
