require 'rubygems'
require 'bundler/setup'

require 'semrush' # and any other gems you need
API_KEY = ENV['API_KEY'] || "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"

RSpec.configure do |config|
  config.filter_run focus: true
  config.run_all_when_everything_filtered = true
end
