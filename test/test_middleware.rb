require_relative 'helper'
require 'rack/lint'
require 'rack/mock'

class ContentType < Hobby::Middleware
  def args content_type = 'text/html'
    @content_type = content_type
  end

  def after
    unless Rack::Utils::STATUS_WITH_NO_ENTITY_BODY.include? @status
      header[Rack::CONTENT_TYPE] ||= @content_type
    end
  end
end

describe Hobby::Middleware do
  def content_type(app, *args)
    Rack::Lint.new ContentType.new(app, *args)
  end
  
  def request
    Rack::MockRequest.env_for
  end
  
  it "set Content-Type to default text/html if none is set" do
    app = lambda { |env| [200, {}, "Hello, World!"] }
    headers = content_type(app).call(request)[1]
    assert { headers['Content-Type'] == 'text/html' }
  end

  it "set Content-Type to chosen default if none is set" do
    app = lambda { |env| [200, {}, "Hello, World!"] }
    headers =
      content_type(app, 'application/octet-stream').call(request)[1]
    assert { headers['Content-Type'] == 'application/octet-stream' }
  end

  it "not change Content-Type if it is already set" do
    app = lambda { |env| [200, {'Content-Type' => 'foo/bar'}, "Hello, World!"] }
    headers = content_type(app).call(request)[1]
    assert { headers['Content-Type'] == 'foo/bar' }
  end

  it "detect Content-Type case insensitive" do
    app = lambda { |env| [200, {'CONTENT-Type' => 'foo/bar'}, "Hello, World!"] }
    headers = content_type(app).call(request)[1]
    headers.to_a.select { |k,v| k.downcase == "content-type" }.must_equal [["CONTENT-Type","foo/bar"]]
  end

  it "not set Content-Type on 304 responses" do
    app = lambda { |env| [304, {}, []] }
    response = content_type(app, "text/html").call(request)
    assert { response[1]['Content-Type'] == nil }
  end
end
