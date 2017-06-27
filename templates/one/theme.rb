#========== Bootstrap Setup ==========#
gem 'sprockets-rails'
gem 'bootstrap', '~> 4.0.0.alpha6'
gem 'jquery-rails'
gem 'jquery-ui-rails'

# tooltips and popovers depend on tether
add_source 'https://rails-assets.org' do
  gem 'rails-assets-tether'
end

inside('app/assets/javascripts') do
  insert_into_file 'application.js', before: '//= require rails-ujs' do
    <<-CODE
//= require jquery
//= require jquery_ujs
//= require tether
//= require bootstrap-sprockets
//= require turbolinks
CODE
  end
end

#========== Theme Setup ==========#
default_theme = :litera
bs_theme = ask('Bootstrap theme name? (Go to https://bootswatch.com/4-alpha/ for available themes.) [default: %s]: ' % default_theme)
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
@import '#{bs_theme}/bootswatch';
@import 'bootstrap';

body {
  margin: 72px auto 0 auto;
}
CODE
end
