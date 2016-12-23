get do
  response.status = 400
  throw :halt, response
end
