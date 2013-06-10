require 'uri'
require 'cgi'
require 'net/http'
require 'csv'
require 'rubygems'
require 'active_support/all'
require 'pony' #for the warning mails
require 'semrush/exception'
require 'semrush/report'

module Semrush
  API_REPORT_URL = "http://%DB%.api.semrush.com/?action=report&type=%REPORT_TYPE%&%REQUEST_TYPE%=%REQUEST%&key=%API_KEY%&display_limit=%LIMIT%&display_offset=%OFFSET%&export=api&export_columns=%EXPORT_COLUMNS%&display_sort=%DISPLAY_SORT%&display_filter=%DISPLAY_FILTER%"
  API_UNITS_URL = "http://www.semrush.com/users/countapiunits.html?key=%API_KEY%"
  mattr_accessor :api_key
  @@api_key = ""
  mattr_accessor :debug
  @@debug = false
  mattr_accessor :before
  @@before = Proc.new{}
  mattr_accessor :after
  @@after = Proc.new{}


  # Email Options (TODO: remove if unnecessary)
  # config.email : recipient for the email notifications (default: nil)
  # config.email_options : Hash with email config (smtp, sendmail, ...). We use the Pony gem to send mails, this hash will be send to Pony.options
  # config.seconds_between_mails : Minimum time (in seconds) between 2 mails with the same subject
  mattr_accessor :email
  mattr_accessor :email_options
  @@email_options = {}
  mattr_accessor :seconds_between_mails
  @@seconds_between_mails = 600
  mattr_accessor :too_many_queries
  @@too_many_queries = {:subject => 'SemRush API: too many queries for the day', :body => 'You made too many requests for today. You should upgrade your plan in order to be able to send more requests to SemRush.'}
  mattr_accessor :too_many_queries_sent_at

  def self.config
    yield self
    Pony.options = @@email_options
    raise Exception::BadApiKey.new if @@api_key.nil? || @@api_key.empty?
    raise Exception::BadArgument.new(self, "before is not a proc: proc type is required.") unless @@before.is_a?(Proc)
    raise Exception::BadArgument.new(self, "after is not a proc: proc type is required.") unless @@after.is_a?(Proc)
  end

end
