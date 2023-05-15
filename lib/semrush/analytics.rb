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

    def initialize params = {}
      @parameters = params
      @target_types = REQUEST_TYPES
      @api_report_url = API_ANALYTICS_URL
    end

    # Get lists domains pointing to the queried domain, root domain, or URL.
    # * :api_key (ex: :api_key => 'gt97s6d4a6w')
    # * :limit (ex: :limit => "")
    # * :offset (ex: :offset => "")
    # * :target_type (ex: :target_type => "") One of `REQUEST_TYPES`
    # * :export_columns (ex: :export_columns => "")
    # * :display_filter one or many of "zone, country, ip, newdomain, lostdomain, category"
    # See: https://developer.semrush.com/api/v3/analytics/backlinks/#reffering_domains
    def self.backlinks_refdomains domain, params = {}
      export_columns = params.delete(:export_columns).presence ||
        "domain_ascore,domain,backlinks_num,ip,country,first_seen,last_seen"

      self.new(params.merge(:report_type => :backlinks_refdomains, :target => domain,
                            :export_columns => export_columns)).request
    end

    private

    # All parameters:
    # * report_type - type of the report
    # * api_key - user identification key, you can find it in your profile on the Semrush site
    # * target_type - type of the request.
    # * target - your domain/url
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
      params.delete(:target_type) unless @target_types.include?(params[:target_type].try(:to_sym))
      @parameters = {:api_key => Semrush.api_key, :limit => "", :offset => "", :export_columns => "",
                     :display_sort => "", :display_filter => "", :display_date => ""}.merge(@parameters).merge(params)
      raise Semrush::Exception::Nolimit.new(self, "The limit parameter is missing: a limit is required.") unless @parameters[:limit].present? && @parameters[:limit].to_i>0
      raise Semrush::Exception::BadArgument.new(self, "Target parameter is missing: Domain name, URL.") unless @parameters[:target].present?
      raise Semrush::Exception::BadArgument.new(self, "Bad report_type: #{@parameters[:report_type]}") unless ANALYTIC_TYPES.include?(@parameters[:report_type].try(:to_sym))
      raise Semrush::Exception::BadArgument.new(self, "Bad target_type: #{@parameters[:target_type]}") unless @target_types.include?(@parameters[:target_type].try(:to_sym))
    end
  end
end
