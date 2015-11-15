Router = Class.new {
  def add_route(*)
  end

  def route_for _request
    Proc.new { 'for any route' }
  end
}.new
