source 'https://rubygems.org'

gemspec

gem 'activesupport', '> 4.0'
gem 'bundler', '~> 1.17'
gem 'faraday', '~> 1.4.1'
gem 'faraday_middleware', '~> 1.0.0'
gem 'rake', '< 11.0' if RUBY_VERSION < '1.9.3'
if RUBY_VERSION < '2.0'
  gem 'rdoc', '< 4.3'
elsif RUBY_VERSION < '2.2.2'
  gem 'rdoc', '< 6'
else
  gem 'rdoc'
end
gem 'rspec'
gem 'webmock'

if RUBY_VERSION >= '2.0'
  gem 'pry', :platforms => :mri
elsif RUBY_VERSION >= '1.9'
  gem 'debugger', :platforms => :mri
else
  gem 'ruby-debug', :platforms => :mri
end
