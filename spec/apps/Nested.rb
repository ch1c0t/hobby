nested_app = Class.new do
  include Hobby::App

  def initialize first, second
    @a = first
    @b = second
    @c = yield
  end

  get do
    "#{@a}:#{@b}:#{@c}"
  end
end

map '/nested', nested_app.new(:a, :b) { :c }
