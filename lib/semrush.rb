require 'uri'
require 'cgi'
require 'net/http'
require 'csv'
require 'rubygems'
require 'active_support/all'
require 'semrush/exception'
require 'semrush/base'
require 'semrush/report'
require 'semrush/analytics'

module Semrush
  # See https://developer.semrush.com/api/v3/analytics/basic-docs/
  API_REPORT_URL = "https://api.semrush.com/?type=%REPORT_TYPE%&%REQUEST_TYPE%=%REQUEST%&key=%API_KEY%&display_limit=%LIMIT%&display_offset=%OFFSET%&export=api&database=%DB%&export_columns=%EXPORT_COLUMNS%&display_sort=%DISPLAY_SORT%&display_filter=%DISPLAY_FILTER%&display_date=%DISPLAY_DATE%"
  API_ANALYTICS_URL = "https://api.semrush.com/analytics/v1?type=%REPORT_TYPE%&targets=%TARGETS%&target_types=%TARGET_TYPES%&target=%TARGET%&target_type=%TARGET_TYPE%&key=%API_KEY%&display_limit=%LIMIT%&display_offset=%OFFSET%&export_columns=%EXPORT_COLUMNS%&display_sort=%DISPLAY_SORT%&display_filter=%DISPLAY_FILTER%"
  API_UNITS_URL = "https://www.semrush.com/users/countapiunits.html?key=%API_KEY%"
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
