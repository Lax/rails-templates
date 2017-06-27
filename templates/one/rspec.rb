gem_group :development, :test do
  gem 'rspec-rails'
end

#========== Spec Setup ==========#
file 'spec/__include_spec.rb', <<-CODE
require 'rails_helper'
Dir[Rails.root.join('spec/support/**/*.rb')].each { |f| require f }
CODE

after_bundle do
  generate 'rspec:install'

  rails_command :spec
end
