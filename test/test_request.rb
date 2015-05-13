require_relative 'minitest_helper'

scope Hobbyte::Request do
  scope '#initialize' do
    it "sets the path info to / if it's empty" do
      env = { 'PATH_INFO' => '', 'REQUEST_METHOD' => 'GET' }
      request = Hobbyte::Request.new env
      assert { request.path_info == '/' }
    end

    it "doesn't change the path info if it's not empty" do
      env = { 'PATH_INFO' => '/hello_world', 'REQUEST_METHOD' => 'GET' }
      request = Hobbyte::Request.new env
      assert { request.path_info == '/hello_world' }
    end
  end
end
