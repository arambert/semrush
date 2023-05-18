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
    def self.backlinks_refdomains(domain, params = {})
      export_columns = params.delete(:export_columns).presence ||
        "domain_ascore,domain,backlinks_num,ip,country,first_seen,last_seen"

      self.new(params.merge(:report_type => :backlinks_refdomains, :target => domain,
                            :export_columns => export_columns))
          .request
    end

    # Compare your and your competitors' backlink profiles and link-building progress.
    # * :api_key (ex: :api_key => 'gt97s6d4a6w')
    # * :targets (ex: :targets => ["domain1.com", "domain2.com"]) Array of domains to compare
    # * :target_types (ex: :target_type => ["root_domain", "root_domain"]) Array to match with corresponding targets index
    # * :export_columns (ex: :export_columns => ""), available columns: "target,target_type,ascore,backlinks_num,domains_num,ips_num,follows_num,nofollows_num,texts_num,images_num,forms_num,frames_num"
    #
    # * Return array of data
    # @see https://developer.semrush.com/api/v3/analytics/backlinks/#batch_comparason
    # @see https://www.semrush.com/batch/report/ for UI demo
    def self.backlinks_comparison(targets, target_types, params = {})
      target_types.each do |target_type|
        raise Exception::BadArgument.new(self, "One of `target_types` is not valid: #{target_type}") unless REQUEST_TYPES.include?(target_type.to_sym)
      end

      raise Exception::BadArgument.new(self, "`targets` and `target_types` must be the same size") unless targets.size == target_types.size

      export_columns = params.delete(:export_columns).presence ||
        "target,target_type,ascore,backlinks_num,domains_num,ips_num,follows_num,nofollows_num,texts_num,images_num,forms_num,frames_num"
      # Have to add target and target_type to params to cleaup API_ANALYTICS_URL (in #request v.blank? check)
      self.new(params.merge(:report_type => :backlinks_comparison, :targets => targets, :target_types => target_types,
                            :export_columns => export_columns,
                            ))
          .request
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
      params.delete(:target_type) unless @target_types.include?(params[:target_type].try(:to_sym)) unless params[:targets]
      @parameters = {:api_key => Semrush.api_key, :limit => "", :offset => "", :export_columns => "",
                     :target => "", :target_type => "", :targets => "", :target_types => "",
                     :display_sort => "", :display_filter => "", :display_date => ""}.merge(@parameters).merge(params)
      # When(if) we will have another method that use `targets` as an Array(like backlinks_comparison) improve this
      # and move validations from backlinks_comparison to here
      unless @parameters[:targets]
        raise Semrush::Exception::Nolimit.new(self, "The limit parameter is missing: a limit is required.") unless @parameters[:limit].present? && @parameters[:limit].to_i>0
        raise Semrush::Exception::BadArgument.new(self, "Target parameter is missing: Domain name, URL.") unless @parameters[:target].present?
        raise Semrush::Exception::BadArgument.new(self, "Bad report_type: #{@parameters[:report_type]}") unless ANALYTIC_TYPES.include?(@parameters[:report_type].try(:to_sym))
        raise Semrush::Exception::BadArgument.new(self, "Bad target_type: #{@parameters[:target_type]}") unless @target_types.include?(@parameters[:target_type].try(:to_sym))
      end
    end
  end
end
