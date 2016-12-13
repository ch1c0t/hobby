route = get '/route' do
  'initial'
end

action = route.action
route.action = ->{ "#{route.verb}:#{instance_exec &action}:#{route.path}" }
