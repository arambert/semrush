require 'uri'
require 'cgi'
require 'net/http'
require 'csv'
require 'rubygems'
require 'active_support/all'
require 'semrush/exception'
require 'semrush/report'

module Semrush
  API_REPORT_URL = "http://api.semrush.com/?type=%REPORT_TYPE%&%REQUEST_TYPE%=%REQUEST%&key=%API_KEY%&display_limit=%LIMIT%&display_offset=%OFFSET%&export=api&database=%DB%&export_columns=%EXPORT_COLUMNS%&display_sort=%DISPLAY_SORT%&display_filter=%DISPLAY_FILTER%&display_date=%DISPLAY_DATE%"
  API_UNITS_URL = "http://www.semrush.com/users/countapiunits.html?key=%API_KEY%"
  mattr_accessor :api_key
  @@api_key = ""
  mattr_accessor :debug
  @@debug = false
  mattr_accessor :before
  @@before = Proc.new{}
  mattr_accessor :after
  @@after = Proc.new{}

  def self.config
    yield self
    raise Exception::BadApiKey.new if @@api_key.nil? || @@api_key.empty?
    raise Exception::BadArgument.new(self, "before is not a proc: proc type is required.") unless @@before.is_a?(Proc)
    raise Exception::BadArgument.new(self, "after is not a proc: proc type is required.") unless @@after.is_a?(Proc)
  end

end
