# frozen_string_literal: true
source "https://rubygems.org"

git_source(:github) {|repo_name| "https://github.com/#{repo_name}" }

# gem "rails"
#gem 'sequel'
gem 'rom-repository'
gem 'rom-sql'
#gem 'jdbc-mysql'
gem 'sinatra'
gem 'sinatra-contrib'
gem 'dry-validation'
gem 'bcrypt'
gem 'json'

platforms :ruby do
  gem 'mysql2'
  gem 'thin'
end

platforms :jruby do
  gem 'trinidad', '~>1.5.0.B2'
end

group :test do
  gem 'rspec'
  gem 'rack-test'
end