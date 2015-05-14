#encoding: UTF-8
source 'http://ruby.taobao.org'


# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.2.0'
# Use sqlite3 as the database for Active Record
gem 'mysql2'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'

gem 'kaminari'

gem "rest-client"
# Use CoffeeScript for .coffee assets and views

#assets
#editor
gem 'rails_kindeditor'
gem 'coffee-rails', '~> 4.1.0'
gem 'jquery-rails'
gem 'jquery-ui-rails'
gem 'bootstrap-sass'
gem 'font-awesome-sass', '~> 4.3.0'
gem 'simple_form'
gem 'jquery-datatables-rails', '~> 3.2.0'
#####END assets ######

#gem 'devise'

gem 'whenever', :require => false
gem 'sidekiq'
gem 'sinatra', :require => nil

gem 'jbuilder', '~> 2.0'
gem 'sdoc', '~> 0.4.0', group: :doc

gem 'quiet_assets', :git => 'git://github.com/AgilionApps/quiet_assets.git'

#图片类
gem 'carrierwave', '0.6.2'
gem 'carrierwave-upyun', '0.1.5'
gem 'rails-assets-for-upyun', '>= 0.0.9'
gem 'mini_magick'

gem 'awesome_print'
# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Unicorn as the app server
# gem 'unicorn'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development
#
gem 'redis-objects'
gem 'dalli'
gem "second_level_cache"

#gem "elasticsearch"
#gem "elasticsearch-rails"
#gem "elasticsearch-model"
#gem 'searchkick'

#gem 'searchkick'

gem 'cancancan', '~> 1.10'

group :test do
  gem 'faker', "~> 1.4.3"
  gem 'fakeweb'
  gem "shoulda-matchers"
  gem 'database_cleaner', "~> 1.3.0"
  gem 'rspec-collection_matchers'
end

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug'

  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console', '~> 2.0'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'

  gem 'rspec-rails', '~> 3.1.0'
  gem 'factory_girl_rails', "~> 4.4.1"
  gem 'pry-rails'
  gem 'pry-nav'
  gem 'thin'

  gem 'capistrano'
  gem 'capistrano-bundler'
  gem 'capistrano-rails'
  gem 'capistrano-rvm'
  gem 'capistrano-sidekiq'
  gem 'capistrano-passenger'
end

# error notify
gem 'exception_notification'

# 日志处理
gem "yell-rails"