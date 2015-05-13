require_relative 'minitest_helper'

scope Hobbyte::Router do
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

  %w(DELETE GET HEAD OPTIONS PATCH POST PUT).each do |verb|
    it 'adds a route' do
      route = app.to_app.class.router.instance_variable_get(:@routes)[verb].first
      assert { route.path == '/' }
    end

    it 'extracts the extra_params' do
      route = app.to_app.class.router.instance_variable_get(:@routes)[verb].last
      assert { route.extra_params == [:name] }
    end
  end
end
