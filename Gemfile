source 'http://rubygems.org'

gem 'rails', '3.1.3'
gem 'mysql2', '0.3.10'
gem 'resque'
gem 'formtastic'
gem 'dwc-archive'
gem 'jquery-rails'
gem 'carrierwave'
gem 'ruby-debug19', :require => 'ruby-debug'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.1.5'
  gem 'coffee-rails', '~> 3.1.1'
  gem 'uglifier', '>= 1.0.3'
end

# To use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# Use unicorn as the web server
# gem 'unicorn'

# Deploy with Capistrano
# gem 'capistrano'

group :test, :development do
  gem 'rspec-rails', '2.7.0'
  gem "escape_utils"
end

group :test do
  gem 'polyglot'
  gem 'capybara', '1.1.2'
  gem 'cucumber', '1.1.4'
  gem 'cucumber-rails', '1.2.1'
  gem 'database_cleaner'
  gem 'bourne'
  gem 'spork'
  gem 'launchy' # So you can do "Then show me the page".
  gem 'mocha'
  gem 'bourne'
  gem 'sham_rack'
  gem 'sinatra', :require => false
  gem 'timecop'
  gem 'factory_girl'
  gem 'shoulda', '>= 3.0.0.beta'
  gem 'turn', '0.8.2', :require => false
end

group :production do
  gem 'thin'
  gem 'rack-google_analytics', '1.0.1', :require => "rack/google_analytics"
end
