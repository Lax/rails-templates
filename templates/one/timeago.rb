gem 'rails-timeago'

inside('app/assets/javascripts') do
  insert_into_file 'application.js', before: '//= require rails-ujs' do
    <<-CODE
//= require rails-timeago
//= require locales/jquery.timeago.zh-CN.js
CODE
  end
end
