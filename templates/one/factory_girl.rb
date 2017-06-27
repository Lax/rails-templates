gem_group :development, :test do
  gem 'factory_girl_rails'
end

file 'spec/support/factory_girl.rb', <<-CODE
RSpec.configure do |config|
  config.include FactoryGirl::Syntax::Methods
end
CODE
