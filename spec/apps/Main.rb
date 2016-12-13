Hobby::VERBS.each do |verb|
  class_eval "#{verb.downcase}('/') { '#{verb}' }"
  class_eval "#{verb.downcase}('/:name') { my[:name] }"
end
