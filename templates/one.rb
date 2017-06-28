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
gem 'title'

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

#========== Config ==========#
inside 'config' do
  run 'mv database.yml database.yml.orig'

  file 'database.yml', <<-CODE
default: &default
  adapter: postgresql
  encoding: utf8
  pool: <%= ENV.fetch("RAILS_MAX_THREADS") { 5 } %>
  username: duang
  password:
  host: localhost

development:
  <<: *default
  url: <%= ENV.fetch("DATABASE_URL") { "sqlite3:%s/%s.sqlite" % [ENV.fetch("DATABASE_DIR", "./db"), Rails.env] } %>

test:
  <<: *default
  url: <%= ENV.fetch("DATABASE_URL") { "sqlite3:%s/%s.sqlite" % [ENV.fetch("DATABASE_DIR", "./db"), Rails.env] } %>

production:
  <<: *default
  username: <%= ENV['DATABASE_USERNAME'] %>
  password: <%= ENV['DATABASE_PASSWORD'] %>
  url: <%= ENV['DATABASE_URL'] %>
CODE
end

#========== Foreman ==========#
file 'Procfile', 'web: bundle exec puma -t 5:5 -p ${PORT:-3000} -e ${RACK_ENV:-development}'
file '.env', <<-CODE
RACK_ENV=development
PORT=4000
SECRET_KEY_BASE=$(rails secret)
CODE

#========== Git ==========#
append_to_file '.gitignore', '/db/*.sqlite'

#========== Layout ==========#
inside 'app/views/layouts/' do
  gsub_file 'application.html.erb', '= yield', %!= render 'layouts/body'!
  insert_into_file 'application.html.erb', %!    <%= stylesheet_link_tag    'http://blog.liulantao.com/iconfont/iconfont/material-icons.css', media: 'all', 'data-turbolinks-track': 'reload' %>\n!, after: %!<%= stylesheet_link_tag    'application', media: 'all', 'data-turbolinks-track': 'reload' %>\n!

  file '_body.html.haml' do
    <<-CODE
= render 'layouts/header'
= render 'layouts/main'
= render 'layouts/footer'
CODE
  end

  file '_header.html.haml' do
    <<-CODE
= render 'layouts/menu'
CODE
  end

  file '_main.html.haml' do
    <<-CODE
%main
  .container<
    = render 'layouts/flash'
  .container<
    = content_for?(:content) ? yield(:content) : yield
CODE
  end

  file '_footer.html.haml' do
    <<-CODE
%footer.footer.text-muted
  .container
    .list-inline
      %a.m-2{href: '/'}<>= t('menu.home')
      \|
      %a.m-2{href: '/'}<>= t('menu.support')

    %p<
      .small<
        = surround " 由", " 提供技术支持" do
          %a<> Lax
CODE
  end

  file '_flash.html.haml' do
    <<-CODE
- flash.each do |name, msg|
  %div{class: flash_class(name, [:flash, :'alert-dismissible']), role: :alert}
    %button.close{type: "button", "data-dismiss": "alert", "aria-label": "Close"}
      %span{"aria-hidden": true} &times;
    %strong= '[%s]' % name
    %span= msg
CODE
  end

  file '_menu.html.haml' do
    <<-CODE
%nav#navbar.navbar.navbar-inverse.bg-primary.fixed-top.navbar-toggleable-sm
  %button.navbar-toggler.navbar-toggler-left.navbar-toggler-right{'aria-controls': 'navbarNavCollapse', 'aria-expanded': 'false', 'aria-label': 'Toggle navigation', 'data-target': '#navbarNavCollapse', 'data-toggle': 'collapse', type: 'button'}
    %span.navbar-toggler-icon

  %a.navbar-brand{href: '#'}<
    %img{alt: :🏝⛵️🍀🌿}

  #navbarNavCollapse.collapse.navbar-collapse
    .navbar-nav.mr-auto
      = link_to :root, class: active_class(root_path, base: 'nav-item nav-link') do
        %i.material-icons.md-18<> home
        = t('menu.home')
        %span.sr-only> (current)
      = content_for?(:controller_menu) ? yield(:controller_menu) : ''

    .navbar-nav
      - if ! user_signed_in?
        = link_to t('menu.sign_up'), :new_user_registration, class: active_class(new_user_registration_path, base: 'nav-item nav-link')
        = link_to t('menu.login'), :new_user_session, class: active_class(new_user_session_path, base: 'nav-item nav-link')
      - else
        .nav-item.dropdown
          %a#navbarProfileMenuLink.nav-link.dropdown-toggle{"aria-expanded": "false", "aria-haspopup": "true", "data-toggle": "dropdown"}
            %i.material-icons.md-18<> person
            = t('menu.profile')
            %span.caret>
          .dropdown-menu.dropdown-menu-right{"aria-labelledby": "navbarProfileMenuLink"}
            %h6.dropdown-header<
              = current_user.email
              %br<
              = precede "@" do
                %b>= current_user.id
            .dropdown-divider
            = link_to t('menu.edit_profile'), :edit_user_registration, class: active_class(edit_user_registration_path, base: 'dropdown-item')
            .dropdown-divider
            = link_to t('menu.logout'), :destroy_user_session, method: :delete, class: active_class(destroy_user_session_path, base: 'dropdown-item')
CODE
  end
end

file 'app/assets/javascripts/navbar_hide.coffee', <<-CODE
$(document).ready ->
  $(window).scroll ->
    if $(this).scrollTop() > 100
      $('#navbar').fadeOut 500
    else
      $('#navbar').fadeIn 500
CODE

#========== Title ==========#
inside 'app/views/layouts/' do
  gsub_file 'application.html.erb', /<title>.*<\/title>/, %!<title><%= title %></title>!
end

file 'config/locales/title.en.yml', <<-CODE
en:
  titles:
    application: #{app_name.camelize}
CODE

#========== Landing ==========#
after_bundle do
  generate :controller, :pages, :landing, '--skip', '--no-helper-specs'
  route %q{root to: 'pages#landing'}

  inside('app/views/pages/') do
    remove_file 'landing.html.haml'
    file 'landing.html.haml', <<-CODE
.d-flex.justify-content-center<>
  %h1 Think different.
CODE
  end

  inside('spec/views/pages/') do
    gsub_file 'landing.html.haml_spec.rb', /^\s.pending .*\n/, <<-CODE
  it 'renders landing' do
    render
    assert_select 'h1'
  end
CODE
  end
end

#========== App Setup ==========#
default_theme = :materia
bs_theme = ask('Bootstrap theme name? (Go to https://bootswatch.com/4-alpha/ for available themes.) [default: %s]: ' % default_theme, :cyan)
bs_theme = default_theme if bs_theme.blank?

inside('app/assets/stylesheets/%s/' % bs_theme) do
  get 'http://bootswatch.com/4-alpha/%s/_variables.scss' % bs_theme, '_variables.scss'
  get 'http://bootswatch.com/4-alpha/%s/_bootswatch.scss' % bs_theme, '_bootswatch.scss'
end

inside('app/assets/stylesheets') do
  run 'mv application.css application.scss'
  insert_into_file 'application.scss', %/ *= require jquery-ui\n/, before: /^\s.*= require_tree \.\n/
  gsub_file 'application.scss', /^\s.*= require_tree \.\n/, ''
  gsub_file 'application.scss', /^\s.*= require_self\n/, ''

  append_to_file 'application.scss', <<-CODE
@import '#{bs_theme}/variables';
@import 'bootstrap';
@import '#{bs_theme}/bootswatch';

body {
  margin: 85px auto 0 auto;
}
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

#========== Devise ==========#
after_bundle do
  unless File.exists? 'config/initializers/devise.rb'
    generate 'devise:install'
    generate 'devise:i18n:locale', :'zh-CN'
    generate :devise, :user
  end

  inside 'spec' do
    insert_into_file 'factories/users.rb', after: %/factory :user do\n/ do
      <<-CODE
    sequence(:email) { |n| "\#{n}@email.com" }
    password Devise.friendly_token[0, 6]

    factory :user_invalid_password do
      password Devise.friendly_token[0, 5]
    end

    factory :user_no_email do
      email nil
    end

    factory :user_no_password do
      password nil
    end
CODE
    end

    gsub_file 'models/user_spec.rb', /^\s.pending .*\n/ do
      <<-CODE
  describe "#create" do
    it "should increment the count" do
      expect{ create(:user) }.to change{User.count}.by(1)
    end

    it "should fail without ::email or :password" do
      expect( build(:user_no_email) ).to be_invalid
      expect( build(:user_no_password) ).to be_invalid
    end
  end

  describe "#email duplicated" do
    it "should fail with UniqueViolation" do
      expect { 2.times {create(:user, email: 'duplicate@email.com')} }.to raise_error(ActiveRecord::RecordInvalid)
    end
  end
CODE
    end
  end
end

#========== Comment ==========#
after_bundle do
  generate :model, :comment, 'user:references', 'content:text', 'commentable:references{polymorphic}:index'

  inject_into_class 'app/models/user.rb', 'User', <<-CODE
has_many :comments
has_many :user_comments, as: :commentable, class_name: 'Comment'
CODE

  inject_into_class 'app/models/comment.rb', 'Comment', <<-CODE
  validates :user, presence: true
  validates :content, presence: true
  validates :commentable, presence: true
CODE

  inside('spec/') do
    gsub_file 'factories/comments.rb', /^\s*user nil$/, '    user'
    gsub_file 'factories/comments.rb', /^\s*content .*$/, '    sequence(:content) {|n| %/Comment Content #{n}/ }'
    gsub_file 'factories/comments.rb', /^\s*commentable nil$/, '    association :commentable, factory: :user'

    insert_into_file 'factories/comments.rb', after: %/association :commentable, factory: :user\n/ do
      <<-CODE

    factory :invalid_comment do
      user nil
      content nil
      commentable nil
    end

    factory :bare_comment do
      user nil
      content nil
      commentable nil
    end
CODE
    end

    gsub_file 'models/comment_spec.rb', /^\s.pending .*\n/, <<-CODE
  it "should increment the count" do
    expect{ create(:comment) }.to change{Comment.count}.by(1)
  end

  it "should fail with bare comment" do
    expect( build(:bare_comment) ).to be_invalid
  end

  it "should fail with invalid" do
    expect( build(:invalid_comment) ).to be_invalid
  end

  it "should fail without :user" do
    expect( build(:comment, user: nil) ).to be_invalid
  end

  it "should fail without :content" do
    expect( build(:comment, content: nil) ).to be_invalid
  end

  it "should fail without :commentable" do
    expect( build(:comment, commentable: nil) ).to be_invalid
  end

  it "should have :commentable_id" do
    expect( create(:comment).commentable ).not_to be(nil)
  end
CODE
  end
end

#========== Helpers ==========#
inside('app/helpers/') do
  insert_into_file 'application_helper.rb', after: %/module ApplicationHelper\n/ do
    <<-CODE
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
CODE
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
  rails_command 'db:migrate'

  generate 'rspec:install'
  rails_command :spec
end
