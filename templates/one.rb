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

#========== Landing ==========#
generate :controller, :pages, :landing, '--skip', '--no-helper-specs'
route %q{root to: 'pages#landing'}

#========== App Setup ==========#
default_theme = :pulse
bs_theme = ask('Bootstrap theme name? (Go to https://bootswatch.com/4-alpha/ for available themes.) [default: %s]: ' % default_theme)
bs_theme = default_theme if bs_theme.blank?
inside('app/assets/stylesheets/%s/' % bs_theme) do
  run 'curl -sSLO http://bootswatch.com/4-alpha/%s/_variables.scss' % bs_theme
  run 'curl -sSLO http://bootswatch.com/4-alpha/%s/_bootswatch.scss' % bs_theme
end

inside('app/assets/stylesheets') do
  remove_file 'application.css'
  create_file 'application.scss', <<-CODE
/*
 *= require jquery-ui
 */

@import '#{bs_theme}/variables';
@import '#{bs_theme}/bootswatch';
@import 'bootstrap';
CODE
end

inside('app/assets/javascripts') do
  insert_into_file 'application.js', before: '//= require rails-ujs' do
    <<-CODE
//= require jquery
//= require jquery_ujs
//= require tether
//= require bootstrap-sprockets
//= require turbolinks
//= require rails-timeago
//= require locales/jquery.timeago.zh-CN.js
CODE
  end
end

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

  rails_command 'spec DATABASE_URL=sqlite3::memory:'
end
