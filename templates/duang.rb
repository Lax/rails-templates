# mini_racer: Minimal embedded v8
gem 'mini_racer', platforms: :ruby

gem_group :development, :test do
  # Use sqlite3 as the database for Active Record
  gem 'sqlite3'
end

gem_group :development, :test do
  gem "factory_girl_rails"
  gem "pry-byebug"
  gem "pry-rails"
  gem "rspec-rails"
end

gem_group :test do
  gem 'rails-controller-testing'
end

# Use jquery as the JavaScript library
gem 'jquery-rails'
gem 'jquery-ui-rails'

# Use Bootstrap
add_source 'https://rails-assets.org' do
  gem 'rails-assets-tether'
end
gem 'sprockets-rails'
gem 'bootstrap', '~> 4.0.0.alpha6'

# Use haml
gem 'haml-rails'

after_bundle do

  generate "rspec:install"

  file 'spec/__include_spec.rb', <<-CODE
require 'rails_helper'
Dir[Rails.root.join('spec/support/**/*.rb')].each { |f| require f }
CODE

  file 'spec/support/factory_girl.rb', <<-CODE
RSpec.configure do |config|
  config.include FactoryGirl::Syntax::Methods
end
CODE

  #rails_command "haml:erb2haml"
  rails_command "db:migrate DATABASE_URL=sqlite3::memory:"
  rails_command "spec DATABASE_URL=sqlite3::memory:"

end	# end after_bundle
