mapped_app = Class.new do
  include Hobby

  def initialize name
    @name = name
  end
  
  get { "The name is #{@name}." }
end

mapping_app = Class.new do
  include Hobby

  map '/first', mapped_app.new('A')
  map '/second', mapped_app.new('B')

  def initialize routes = {}
    routes.each do |route, app|
      map route, app
    end
  end
end

map '/1', mapping_app.new

routes = { '/third' => mapped_app.new('C') }
map '/2', mapping_app.new(routes)
