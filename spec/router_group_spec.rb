require 'helper'

describe Hobby::RSpec::Router do
  before do
    @Group = Class.new do
      def subject
        @router ||= Hobby::Router.new
      end
    end.include described_class
  end

  it 'contains a few helpers in its singleton' do
    [:env_for, :add_routes, :find_route].each do |name|
      assert { @Group.respond_to? name }
    end
  end

  describe 'env_for' do
    context 'two arguments passed' do
      it 'returns an environment' do
        env = { "REQUEST_METHOD" => 'POST', "PATH_INFO" => '/some_path' }
        assert { env == (@Group.env_for '/some_path', 'POST') }
      end
    end

    context 'one argument passed' do
      it 'defaults to GET' do
        env = { "REQUEST_METHOD" => 'GET', "PATH_INFO" => '/some_path' }
        assert { env == (@Group.env_for '/some_path') }
      end
    end
  end

  describe 'add_routes' do
    it do
      routes = %w! first second third!
      group = @Group.new

      group.add_routes *routes

      routes.each do |route|
        expect(group.subject.route_for group.env_for 'first').to be_truthy
      end
    end
  end
end
