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
      it { is_expected.to be_a Rack::URLMap }
    end

    context 'an app without nested app(s)' do
      let(:subject) { build_app(Main).new }
      it { is_expected.to be_a Hobby::App }
    end
  end

  describe :integration do
    before do
      described_class.app = build_app described_class
    end

    def app
      described_class.app.new
    end

    describe Main do
      Hobby::Verbs.each do |verb|
        context 'when the request matches a route' do
          it "matches #{verb} ''" do
            send verb.downcase, ''
            assert { last_response.ok? }
            assert { verb == last_response.body }
          end

          it 'matches #{verb} /' do
            send verb.downcase, '/'
            assert { last_response.ok? }
            assert { verb == last_response.body }
          end

          it 'matches #{verb} /route.json' do
            send verb.downcase, '/route.json'
            assert { last_response.ok? } 
            assert { "#{verb} /route.json" == last_response.body }
          end

          it 'matches #{verb} /route/:id.json' do
            send verb.downcase, '/route/1.json'
            assert { last_response.ok? }
            assert { last_response.body == '1' }
          end

          it 'matches #{verb} /:name' do
            send verb.downcase, '/hobbit'
            assert { last_response.ok? }
            assert { last_response.body == 'hobbit' }

            send verb.downcase, '/hello-hobbit'
            assert { last_response.ok? }
            assert { last_response.body == 'hello-hobbit' }
          end
        end

        context 'when the request not matches a route' do
          it 'responds with 404 status code' do
            send verb.downcase, '/not/found'
            assert { last_response.not_found? }
            assert { last_response.body.empty? }
          end
        end
      end
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

    describe Halt do
      it 'halts the execution with a response' do
        get '/halt'
        assert { last_response.status == 501 }
      end

      it 'halts the execution with a finished response' do
        get '/halt_finished'
        assert { last_response.status == 404 }
      end

      it do
        get '/increment_instance_variable'
        assert { last_response.body == '1' }
        get '/increment_instance_variable'
        assert { last_response.body == '1' }
      end

      it do
        get '/route'
        assert { last_response.body == 'nested route' }

        get '/route/'
        assert { last_response.body == 'nested route' }
      end

      it do
        browser = Rack::Test::Session.new Rack::MockSession.new (build_app described_class).new

        browser.get '/route'
        assert { browser.last_response.body == 'nested route' }

        browser.get '/route/'
        assert { browser.last_response.body == 'nested route' }
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
        get '/ping?1=2&3=4'
        assert { last_response.body == '1=2&3=4' }

        get '/ping?why=42'
        assert { last_response.body == 'why=42' }
      end

      it do
        get '/for_request?key=value'
        assert { last_response.body == 'value' }
      end

      it do
        get '/for_my'
        assert { last_response.body == 'true' }

        get '/for_direct_path_params'
        assert { last_response.body == 'true' }
      end
    end

    describe Nested do
      it do
        get '/nested'
        assert { last_response.body == 'a:b:c' }
      end

      it 'should be able to access a route with and without /' do
        get '/nested/route'
        assert { last_response.body == 'nested route' }

        get '/nested/route/'
        assert { last_response.body == 'nested route' }

        get '/nested/path_variable'
        assert { last_response.body == 'path_variable' }

        get '/nested/path_variable/'
        assert { last_response.body == 'path_variable' }
      end
    end
  end
end
