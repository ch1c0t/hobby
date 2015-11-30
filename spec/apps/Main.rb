Hobby::Verbs.each do |verb|
  class_eval "#{verb.downcase}('/') { '#{verb}' }"
  class_eval "#{verb.downcase}('/route.json') { '#{verb} /route.json' }"
  class_eval "#{verb.downcase}('/route/:id.json') { my[:id] }"
  class_eval "#{verb.downcase}('/:name') { my[:name] }"
end
