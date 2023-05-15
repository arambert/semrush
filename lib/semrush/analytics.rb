module Semrush
  # = Analytics Class
  # Most of these methods take a hash parameter that may contain the following keys :
  # There is no db filter for analytics api but you can use :display_filter to filter the results,
  #   example: :display_filter => "+|country||us" will only return results from the US.
  # See https://developer.semrush.com/api/v3/analytics/basic-docs/
  # * :api_key (ex: :api_key => 'gt97s6d4a6w')
  # * :limit (ex: :limit => 2000)
  # * :offset (ex: :offset => 5)
  # * :export_columns (ex: :export_columns => "Dn,Rk")
  class Analytics < Base
    ANALYTIC_TYPES = [:backlinks_refdomains]
    REQUEST_TYPES = [:root_domain, :domain, :url]

    # Tries to make the api call for the report called as method (see samples on http://www.semrush.com/api.html).
    def method_missing(method, *args)
      return super unless ANALYTIC_TYPES.include?(method) && args.first.is_a?(Hash)
      request args.first.merge(:report_type => method)
    end

    def initialize params = {}
      @parameters = params
      @request_types = REQUEST_TYPES
    end

    # Get lists domains pointing to the queried domain, root domain, or URL.
    # * :api_key (ex: :api_key => 'gt97s6d4a6w')
    # * :limit (ex: :limit => "")
    # * :offset (ex: :offset => "")
    # * :export_columns (ex: :export_columns => "")
    def self.backlinks_refdomains domain, params = {}
      self.new(params.merge(:request_type => :backlinks_refdomains, :request => domain))
    end

    private

    # All parameters:
    # * report_type - type of the report
    # * api_key - user identification key, you can find it in your profile on the Semrush site
    # * request_type - type of the request.
    # * request - your request
    # * limit - number of results returned
    # * offset - says to skip that many results before beginning to return results to you
    # * export_columns - list of column names, separated by coma. You may list just the column names you need in an order you need.
    # * display_sort - a sorting as a String eg: 'am_asc' or 'am_desc'(read http://www.semrush.com/api)
    # * display_filter - list of filters separated by "|" (maximum number - 25). A filter consists of <sign>|<field>|<operation>|<value> (read http://www.semrush.com/api)
    #
    # more details in http://www.semrush.com/api.html
    def validate_parameters params = {}
      params.symbolize_keys!
      params.delete(:report_type) unless ANALYTIC_TYPES.include?(params[:report_type].try(:to_sym))
      params.delete(:request_type) unless REQUEST_TYPES.include?(params[:request_type].try(:to_sym))
      @parameters = {:api_key => Semrush.api_key, :limit => "", :offset => "", :export_columns => "",
                     :display_sort => "", :display_filter => "", :display_date => ""}.merge(@parameters).merge(params)
      raise Semrush::Exception::Nolimit.new(self, "The limit parameter is missing: a limit is required.") unless @parameters[:limit].present? && @parameters[:limit].to_i>0
      raise Semrush::Exception::BadArgument.new(self, "Request parameter is missing: Domain name, URL, or keywords are required.") unless @parameters[:request].present?
      raise Semrush::Exception::BadArgument.new(self, "Bad db: #{@parameters[:db]}") unless DBS.include?(@parameters[:db].try(:to_sym))
      raise Semrush::Exception::BadArgument.new(self, "Bad report type: #{@parameters[:report_type]}") unless ANALYTIC_TYPES.include?(@parameters[:report_type].try(:to_sym))
      raise Semrush::Exception::BadArgument.new(self, "Bad request type: #{@parameters[:request_type]}") unless REQUEST_TYPES.include?(@parameters[:request_type].try(:to_sym))
    end
  end
end
