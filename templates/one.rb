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
after_bundle do
  inside('app/views/pages/') do
    create_file 'landing.html.haml', %Q{.d-flex.justify-content-center<>
  %h1 Think different.}
  end

  generate :controller, :pages, :landing, '--skip', '--no-helper-specs'
  route %q{root to: 'pages#landing'}

  inside('spec/views/pages/') do
    gsub_file 'landing.html.haml_spec.rb', /^\s.pending .*\n/, %q{  it 'renders landing' do
    render
    assert_select 'h1'
  end
}
  end
end

#========== App Setup ==========#
default_theme = :pulse
bs_theme = ask('Bootstrap theme name? (Go to https://bootswatch.com/4-alpha/ for available themes.) [default: %s]: ' % default_theme)
bs_theme = default_theme if bs_theme.blank?
inside('app/assets/stylesheets/%s/' % bs_theme) do
  run 'curl -sSLO http://bootswatch.com/4-alpha/%s/_variables.scss' % bs_theme
  run 'curl -sSLO http://bootswatch.com/4-alpha/%s/_bootswatch.scss' % bs_theme
end

inside('app/assets/stylesheets') do
  run 'mv application.css application.scss'
  insert_into_file 'application.scss', %/ *= require jquery-ui\n/, before: /^\s.*= require_tree \.\n/
  gsub_file 'application.scss', /^\s.*= require_tree \.\n/, ''
  gsub_file 'application.scss', /^\s.*= require_self\n/, ''

  append_to_file 'application.scss', %Q{
@import '#{bs_theme}/variables';
@import '#{bs_theme}/bootswatch';
@import 'bootstrap';
}
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

#========== Helpers ==========#
inside('app/helpers/') do
  insert_into_file 'application_helper.rb', after: 'module ApplicationHelper' do
    %Q{
  def active_class(link_path, base: '')
    append_class(link_path, append: 'active', base: base)
  end

  def append_class(link_path, append: '', base: '')
    current_page?(link_path) ? [append, base].join(' ') : base
  end

  def flash_class(level, default=[])
    cls = case level.to_sym
      when :notice then [:alert, :'alert-info']
      when :success then [:alert, :'alert-success']
      when :error then [:alert, :'alert-danger']
      when :alert then [:alert, :'alert-warning']
      else []
    end
    return cls + default
  end
}
  end
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
