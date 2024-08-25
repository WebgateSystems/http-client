require './lib/http_client/version'

Gem::Specification.new do |s|
  s.name        = "http_client"
  s.version     = WS::HttpClient::VERSION::STRING
  s.author      = "Jerzy Sladkowski"
  s.email       = "sladkowski@webgate.pro"
  s.homepage    = "https://github.com/WebgateSystems/http-client"
  s.description = "Lightweight http connection wrapper."
  s.summary     = "HttpClient provide nice interface to handle http connections and errors really efficient."
  s.license     = "MIT"

  s.extra_rdoc_files = %w[ README.md ]

  s.add_dependency('faraday')

  s.add_development_dependency('bundler', '>= 2.5.17')
  s.add_development_dependency('rake', '> 0.8.7')
  s.add_development_dependency('rspec', '~> 3.13')
  s.add_development_dependency('rdoc')
  s.add_development_dependency('pry')
  s.add_development_dependency('webmock')

  s.files = %w[ README.md LICENSE ] + Dir.glob("lib/**/*")
end
