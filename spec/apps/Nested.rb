map('/nested') do
  run NestedApp.new(:a, :b) {
    :c
  }
end

class NestedApp
  include Hobby::App

  def initialize first, second
    @a = first
    @b = second
    @c = yield
  end

  get do
    "#{@a}:#{@b}:#{@c}"
  end

  get '/route' do
    'nested route'
  end

  get '/:route' do
    request.params[:route]
  end
end
