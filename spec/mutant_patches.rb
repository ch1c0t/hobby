# Run all the specs for any subject.
class Mutant::Selector::Expression
  def call _subject
    integration.all_tests
  end
end

# Do not silence stdout and stderr of the running mutation.
class Mutant::Isolation::Fork
  def result
    yield
  end
end

# Print the source of the current mutation.
class Mutant::Loader
  def call
    source = Unparser.unparse node

    puts <<~S
      Current mutation:
      #{source}
    S

    kernel.eval source, binding, subject.source_path.to_s, subject.source_line
  end
end
