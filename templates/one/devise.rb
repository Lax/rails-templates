gem 'devise'
gem 'devise-i18n'

file 'spec/support/devise.rb', <<-CODE
RSpec.configure do |config|
  config.include Devise::Test::ControllerHelpers, type: :controller
  config.include Devise::Test::ControllerHelpers, type: :view
  config.include Devise::Test::IntegrationHelpers, type: :feature
  config.include Devise::Test::IntegrationHelpers, type: :request
end
CODE

#========== User ==========#
after_bundle do
  unless File.exists? 'config/initializers/devise.rb'
    generate 'devise:install'
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
