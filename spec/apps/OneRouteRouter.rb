self.router = Class.new {
  def add_route(*)
  end

  def route_for _request
    -> { 'for any route' }
  end
}.new
