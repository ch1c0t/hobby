require 'helper'
require 'rack/test'

Dir['spec/apps/*.rb'].each do |file|
  name = File.basename file, '.rb'
  body = IO.read file

  eval %!
    class #{name} < Hobby::App
      #{body}
    end
  !
end

describe Hobby::App do
  include Rack::Test::Methods

  def app
    described_class.new
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

  describe CustomMembers do
    it 'works' do
      get '/'
      assert { last_response.body == 'it works' }
    end
  end

  describe Env do
    it do
      get '/ping?1=2&3=4'
      assert { last_response.body == '1=2&3=4' }

      get '/ping?why=42'
      assert { last_response.body == 'why=42' }
    end
  end
end
