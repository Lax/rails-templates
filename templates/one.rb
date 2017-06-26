#========== Rails Gems ==========#
gem 'rails'

gem 'sprockets-rails'
gem 'bootstrap', '~> 4.0.0.alpha6'
gem 'jquery-rails'
gem 'jquery-ui-rails'
gem 'haml-rails'
gem 'pg'
gem 'puma'
gem 'rails-timeago'
gem 'devise'

# i18n
gem 'rails-i18n'
gem 'devise-i18n'
gem 'globalize', github: 'globalize/globalize'
gem 'activemodel-serializers-xml'

add_source 'https://rails-assets.org' do
  gem 'rails-assets-tether'
end

gem_group :development do
  gem 'listen'
  gem 'spring'
  gem 'spring-commands-rspec'
  gem 'web-console'
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'rails_best_practices'
end

gem_group :test do
  gem 'rails-controller-testing'

  gem 'database_cleaner'
  gem 'launchy'
  gem 'shoulda-matchers'
  gem 'simplecov', require: false
  gem 'timecop'
  gem 'webmock'

  #gem 'headless'
  #gem 'capybara-webkit'
  #gem 'formulaic'
end

gem_group :development, :test do
  gem 'sqlite3'

  gem 'awesome_print'
  gem 'bullet'
  gem 'bundler-audit', '>= 0.5.0', require: false
  gem 'dotenv-rails'
  gem 'factory_girl_rails'
  gem 'pry-byebug'
  gem 'pry-rails'
  gem 'rspec-rails'
end

gem_group :development, :staging do
  gem 'rack-mini-profiler', require: false
end

#========== App Setup ==========#
after_bundle do
  generate 'devise:install'

  rails_command 'db:migrate DATABASE_URL=sqlite3::memory:'
end

#========== Spec Setup ==========#
file 'spec/__include_spec.rb', <<-CODE
require 'rails_helper'
Dir[Rails.root.join('spec/support/**/*.rb')].each { |f| require f }
CODE

file 'spec/support/factory_girl.rb', <<-CODE
RSpec.configure do |config|
  config.include FactoryGirl::Syntax::Methods
end
CODE

file 'spec/support/devise.rb', <<-CODE
RSpec.configure do |config|
  config.include Devise::Test::ControllerHelpers, type: :controller
  config.include Devise::Test::ControllerHelpers, type: :view
  config.include Devise::Test::IntegrationHelpers, type: :feature
  config.include Devise::Test::IntegrationHelpers, type: :request
end
CODE

after_bundle do
  generate 'rspec:install'

  rails_command "spec DATABASE_URL=sqlite3::memory:"
end
