self.router = Class.new {
  def add_route(*)
  end

  def route_for _request
    -> { 'for any route' }
  end

  attr_accessor :app

  def to_rack_app
    builder = Rack::Builder.new
    builder.run app
    builder.to_app
  end
}.new
