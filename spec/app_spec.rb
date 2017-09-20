require 'helper'
require 'rack/test'

$sources = {}

Dir['spec/apps/*.rb'].each do |file|
  name = File.basename file, '.rb'

  eval %!
    class #{name}
      class << self
        attr_accessor :app
      end
    end
  !

  $sources[Object.const_get name] = IO.read file
end

def build_app described_class
  body = $sources[described_class]

  eval %!
    Class.new do
      include Hobby::App
      #{body}
    end
  !
end

describe Hobby::App do
  include Rack::Test::Methods

  describe '.new' do
    context 'an app with nested app(s)' do
      let(:subject) { build_app(Nested).new }
      it { should be_a Rack::URLMap }
    end

    context 'an app without nested app(s)' do
      let(:subject) { build_app(Main).new }
      it { should be_a Hobby::App }
    end
  end

  describe '#call' do
    def app
      build_app(Main).new
    end

    context 'when a route was found' do
      it 'evaluates the route' do
        get '/existent'

        assert { last_response.ok? }
        assert { last_response.body == 'existent' }
      end
    end

    context 'when a route was not found' do
      it 'responds with 404 status code' do
        get '/nonexistent/route'

        assert { last_response.not_found? }
      end
    end

    it 'gives a distinct object to each request' do
      get '/first'
      assert { last_response.body == 'first' }

      get '/second'
      assert { last_response.body != 'first' }
      assert { last_response.body == 'second' }
    end
  end

  describe '#router' do
    it 'gives a distinct router to each app' do
      app = Class.new { include Hobby }

      first_instance = app.new
      second_instance = app.new

      assert { not first_instance.router.equal? second_instance.router }
    end
  end

  describe :integration do
    before do
      described_class.app = build_app described_class
    end

    def app
      described_class.app.new
    end

    describe Map do
      it 'mounts an application to the rack stack' do
        get '/map'
        assert { last_response.body == 'from map' }
      end

      it 'mounts an application to the rack stack with old deprecated syntax' do
        get '/deprecated_map'
        assert { last_response.body == 'from deprecated map' }
      end
    end

    describe MapInsideInitialize do
      describe 'without any passed arguments' do
        def app
          described_class.app.new
        end

        it do
          get '/'
          assert { last_response.body == 'hello world' }
          get '/first_map'
          assert { last_response.body == 'first mapapp' }
          get '/second_map'
          assert { last_response.body == 'second mapapp' }
        end
      end

      describe 'with passed routes' do
        def app
          some_app = Class.new {
            include Hobby
            get { 'Some string.' }
          }
          routes = { '/third_map' => some_app.new }
          described_class.app.new routes
        end

        it do
          get '/'
          assert { last_response.body == 'hello world' }
          get '/first_map'
          assert { last_response.body == 'first mapapp' }
          get '/second_map'
          assert { last_response.body == 'second mapapp' }

          get '/third_map'
          assert { last_response.body == 'Some string.' }
        end
      end
    end

    describe Use do
      it 'adds a middleware to the rack stack' do
        get '/use'
        assert { last_response.body == 'from use' }
      end
    end

    describe UseInsideInitialize do
      it do
        get '/'
        assert { last_response.content_type == 'application/json' }
      end
    end

    describe WithoutPath do
      it 'is accessible as /' do
        get '/'
        assert { last_response.body == 'root' }
      end
    end

    describe OneRouteRouter do
      it 'returns for any route' do
        get '/'
        assert { last_response.body == 'for any route' }

        get '/some-other-route'
        assert { last_response.body == 'for any route' }
      end
    end

    describe Env do
      it do
        get '/query_string?1=2&3=4'
        assert { last_response.body == '1=2&3=4' }
      end

      it do
        get '/access_params?key=value'
        assert { last_response.body == 'value' }
      end

      it do
        get '/access_path_params_via_my'
        assert { last_response.body == 'true' }

        get '/access_path_params_via_env'
        assert { last_response.body == 'true' }
      end
    end

    describe Nested do
      it do
        get '/nested'
        assert { last_response.body == 'a:b:c' }
      end
    end

    describe Decorator do
      it do
        get '/route'
        assert { last_response.body == 'GET:initial:/route' }
      end
    end

    describe Halting do
      it do
        get '/'
        assert { last_response.status == 400 }
      end
    end

    describe ContentType do
      it do
        get '/'
        assert { last_response.body == "alert('string');" }
        assert { last_response.headers['Content-Type'] == 'application/javascript' }
      end
    end

    describe Status do
      it do
        get '/'
        assert { last_response.status == 201 }
        assert { last_response.body == 'Created.' }
      end
    end

    describe UnshareableRouterMaps do
      it do
        get '/1/first'
        assert { last_response.body == 'The name is A.' }
        get '/1/second'
        assert { last_response.body == 'The name is B.' }
        get '/1/third'
        assert { last_response.body == '404' }

        get '/2/first'
        assert { last_response.body == 'The name is A.' }
        get '/2/second'
        assert { last_response.body == 'The name is B.' }
        get '/2/third'
        assert { last_response.body == 'The name is C.' }

        get '/3/first'
        assert { last_response.body == 'The name is A.' }
        get '/3/second'
        assert { last_response.body == 'The name is B.' }
        get '/3/third'
        assert { last_response.body == '404' }
      end
    end

    describe UnshareableRouterUses do
      it do
        get '/1'
        assert { last_response.content_type == 'application/html' }
        
        get '/2'
        assert { last_response.content_type == 'application/json' }

        get '/3'
        assert { last_response.content_type == 'application/html' }
      end
    end
  end
end
