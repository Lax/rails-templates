#========== Rails Gems ==========#
gem 'rails'

gem 'haml-rails'
gem 'pg'
gem 'puma'

# i18n
gem 'rails-i18n'
gem 'globalize', github: 'globalize/globalize'
gem 'activemodel-serializers-xml'
gem 'title'

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
  gem 'pry-byebug'
  gem 'pry-rails'
end

gem_group :development, :staging do
  gem 'rack-mini-profiler', require: false
end

after_bundle do
  p [:dir, __dir__, :source_paths, source_paths]
  %w{database devise factory_girl landing layout theme timeago rspec git}.each do |fn|
    say 'Applying %s' % fn, :cyan
    fp = 'one/%s.rb' % fn
    sfp = '%s/%s' % [__dir__, fp]
    get sfp, fp
    rails_command 'app:template LOCATION=%s' % fp
  end

  say 'All modules installed!', :cyan
end
