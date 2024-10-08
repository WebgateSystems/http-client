# frozen_string_literal: true
$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

begin
  if RUBY_VERSION >= '2.0'
    require 'pry'
  elsif RUBY_VERSION >= '1.9'
    require 'debugger'
  else
    require 'ruby-debug'
  end
rescue LoadError
end

require 'http_client'
