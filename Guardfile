guard(:bundler) { watch("Gemfile") }
guard :rspec, all_after_pass: false, all_on_start: false do
  watch(%r{^spec/(.+)_spec\.rb$})
  watch(%r{^lib/(.+)\.rb$}) { |f| "spec/#{f[1]}_spec.rb" }
end
