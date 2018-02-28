get do
  script_name
end

app = Class.new do
  include Hobby
  get do
    script_name
  end
end

map '/some/path', app.new
