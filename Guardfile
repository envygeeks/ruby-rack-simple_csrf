guard :rspec, all_after_pass: false, all_on_start: false do
  watch(%r{^spec/(.+)_spec\.rb$})
  watch(%r{^lib/(.+)\.rb$}) do |file|
    "spec/lib/#{file[1]}_spec.rb"
  end
end
