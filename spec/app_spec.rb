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
        assert { last_response.body.empty? }
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
    end

    describe Use do
      it 'adds a middleware to the rack stack' do
        get '/use'
        assert { last_response.body == 'from use' }
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
  end
end
