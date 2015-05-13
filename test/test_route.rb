require_relative 'minitest_helper'

scope Hobbyte::Router::Route do
  scope '#initialize' do
    def route path
      Hobbyte::Router::Route.new path, &block
    end

    def block
      Proc.new { |env| [200, {}, []] }
    end

    it 'compiles /' do
      path = '/'
      route = route path
      assert_equal block.call({}), route.to_proc.call({})
      assert_equal /^\/$/.to_s, route.compiled_path.to_s
      assert_equal [], route.extra_params
      assert_equal path, route.path
    end

    it 'compiles with .' do
      path = '/route.json'
      route = route path
      assert_equal block.call({}), route.to_proc.call({})
      assert_equal /^\/route.json$/.to_s, route.compiled_path.to_s
      assert_equal [], route.extra_params
      assert_equal path, route.path
    end

    it 'compiles with -' do
      path = '/hello-world'
      route = route path
      assert_equal block.call({}), route.to_proc.call({})
      assert_equal /^\/hello-world$/.to_s, route.compiled_path.to_s
      assert_equal [], route.extra_params
      assert_equal path, route.path
    end

    it 'compiles with params' do
      path = '/hello/:name'
      route = route path
      assert_equal block.call({}), route.to_proc.call({})
      assert_equal /^\/hello\/([^\/?#]+)$/.to_s, route.compiled_path.to_s
      assert_equal [:name], route.extra_params
      assert_equal path, route.path

      path = '/say/:something/to/:someone'
      route = route path
      assert_equal block.call({}), route.to_proc.call({})
      assert_equal /^\/say\/([^\/?#]+)\/to\/([^\/?#]+)$/.to_s, route.compiled_path.to_s
      assert_equal [:something, :someone], route.extra_params
      assert_equal path, route.path
    end

    it 'compiles with . and params' do
      path = '/route/:id.json'
      route = route path
      assert_equal block.call({}), route.to_proc.call({})
      assert_equal /^\/route\/([^\/?#]+).json$/.to_s, route.compiled_path.to_s
      assert_equal [:id], route.extra_params
      assert_equal path, route.path
    end
  end
end
