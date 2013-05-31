module Semrush
  # =Report Class
  # Most of these methods take a hash parameter that may contain the following keys :
  # * :db (ex: :db => "us")
  # * :api_key (ex: :api_key => 'gt97s6d4a6w')
  # * :limit (ex: :limit => 2000)
  # * :offset (ex: :offset => 5)
  # * :export_columns (ex: :export_columns => "Dn,Rk")
  class Report
    DBS = [:us, :uk, :ru, :de, :fr, :es, :it, :br, :au] #"us" - for Google.com, "uk" - for Google.co.uk, "ru" - for Google.ru, "de" for Google.de, "fr" for Google.fr, "es" for Google.es, "it" for Google.it Beta, "br" for Google.com.br Beta, "au" for Google.com.au Beta.
    REPORT_TYPES = [:domain_rank, :domain_organic, :domain_adwords, :domain_organic_organic, :domain_adwords_adwords, :domain_organic_adwords, :domain_adwords_organic,
                    :phrase_this, :phrase_related,
                    :url_organic, :url_adwords]
    REQUEST_TYPES = [:domain, :phrase, :url]


    # Tries to make the api call for the report called as method (see samples on http://www.semrush.com/api.html).
    # Allows calls like:
    # * Semrush::Report.new.domain_rank(:request_type => :domain, :request => 'thedomain.com')
    # * Semrush::Report.new.domain_organic_organic(:request_type => :domain, :request => 'thedomain.com')
    # * Semrush::Report.new.phrase_related(:request_type => :phrase, :request => 'the phrase')
    def method_missing(method, *args)
      return super unless REPORT_TYPES.include?(method) && args.first.is_a?(Hash)
      request args.first.merge(:report_type => method)
    end

    def initialize params = {}
      @parameters = params
    end

    # Initializes a report for a specific domain.
    # Takes a hash parameter that may contain the following keys :
    # * :db (ex: :db => "us")
    # * :api_key (ex: :api_key => 'gt97s6d4a6w')
    # * :limit (ex: :limit => "")
    # * :offset (ex: :offset => "")
    # * :export_columns (ex: :export_columns => "")
    def self.domain domain, params = {}
      self.new(params.merge(:request_type => :domain, :request => domain))
    end
    # Initializes a report for a specific phrase (or keyword).
    # Takes a hash parameter that may contain the following keys :
    # * :db (ex: :db => "us")
    # * :api_key (ex: :api_key => 'gt97s6d4a6w')
    # * :limit (ex: :limit => "")
    # * :offset (ex: :offset => "")
    # * :export_columns (ex: :export_columns => "")
    def self.phrase phrase, params = {}
      self.new(params.merge(:request_type => :phrase, :request => phrase))
    end
    # Initializes a report for a specific domain.
    # Takes a hash parameter that may contain the following keys :
    # * :db (ex: :db => "us")
    # * :api_key (ex: :api_key => 'gt97s6d4a6w')
    # * :limit (ex: :limit => "")
    # * :offset (ex: :offset => "")
    # * :export_columns (ex: :export_columns => "")
    def self.url url, params = {}
      self.new(params.merge(:request_type => :url, :request => url))
    end

    # Initializes & calls a report for the remaining API units
    # Takes a hash parameter that may contain the following keys :
    # * :api_key (ex: :api_key => 'gt97s6d4a6w')
    def self.remaining_quota params = {}
      @remaining_quota_url ||= begin
        temp_url = "#{API_UNITS_URL}" #do not copy the constant as is or else the constant would be modified !!
        params = {:api_key => Semrush.api_key}.merge(params)
        params.each {|k, v|
          if v.blank?
            temp_url.gsub!(/&[^&=]+=%#{k.to_s}%/i, '')
          else
            temp_url.gsub!("%#{k.to_s.upcase}%", URI.escape(v.to_s).gsub('&', '%26'))
          end
        }
        temp_url
      end
      puts "[Semrush query] URL: #{@remaining_quota_url}" if Semrush.debug
      url = URI.parse(@remaining_quota_url)
      response = Net::HTTP.start(url.host, url.port) {|http|
        http.get(url.path+"?"+url.query)
      }
      body = response.body
      if body.blank? && response['location'].present?  && response['location']!=@remaining_quota_url
        @remaining_quota_url = URI.join("http://#{url.host}", response['location']).to_s
        self.remaining_quota params
      else
        body.force_encoding("utf-8")
        body.starts_with?("ERROR") ? error(body) : body.to_i
      end
    end

    # Main report.
    # Available for a phrase or a domain.
    # Default columns for a domain:
    # * Dn - A site name.
    # * Rk - Rating of sites by the number of visitors coming from the first 20 Google search results
    # * Or - Keywords that this site has in TOP20 Google Organic results
    # * Ot - Estimated number of visitors coming from the first 20 Google search results (per month)
    # * Oc - Estimated cost of purchasing the same number of visitors
    # * Ad - Keywords that this site has in TOP20 Google AdWords
    # * At - Estimated number of visitors coming from AdWords (per month)
    # * Ac - Estimated expenses of the site for the advertising in AdWords (per month)
    # Default columns for a phrase:
    # * Ph - The search query which the site has within the first 20 Google search results
    # * Nq - Average number of queries of this keyword in a month, for the corresponding local version of Google
    # * Cp - Average price of a click on the AdWords ad for this search query, in U.S. dollars
    # * Co - Competition of advertisers in AdWords for that term, the higher is the number - the higher is the competition
    # * Nr - The number of search results - how many pages does Google know for this query
    def basics params = {}
      domain? ? request(params.merge(:report_type => :domain_rank)) : request(params.merge(:report_type => :phrase_this))
    end
    
    # Organic Keywords report
    # Can be called for a domain or a URL.
    # Default columns for a domain:
    # * Ph - The search query which the site has within the first 20 Google search results
    # * Po - The position of the site for the search query in Google, at the moment of data collection
    # * Pp - The position of the site for the search query in Google, for the previous data collection
    # * Nq - Average number of queries of this keyword in a month, for the corresponding local version of Google
    # * Cp - Average price of a click on the AdWords ad for this search query, in U.S. dollars
    # * Ur - URL of a page of the site which is displayed in search results for this query (landing page)
    # * Tr - The ratio of the number of visitors coming to the site from this search request to all visitors coming from Google search results
    # * Tc - The ratio of the estimated cost of buying the same number of visitors for this search query to the estimated cost of purchasing the same number of targeted visitors coming to this site from Google search results
    # * Co - Competition of advertisers in AdWords for that term, the higher is the number - the higher is the competition
    # * Nr - The number of search results - how many pages does Google know for this query
    # * Td - Dynamics of change in the number of search queries in the past 12 months (estimated)
    # Default columns for a URL:
    # * Ph - Search query that the URL has within the first 20 Google Organic or AdWords results
    # * Po - The position of this URL for this keyword in Organic or AdWords results
    # * Nq - Average number of queries of this keyword in a month, for the corresponding local version of Google
    # * Cp - Average price of a click on the AdWords ad for this search query, in U.S. dollars
    # * Co - Competition of advertisers in AdWords for that term, the higher is the number - the higher is the competition
    # * Tr - The ratio of the number of visitors coming to the URL from this keyword to all visitors coming
    # * Tc - The ratio of the estimated cost of buying the same number of visitors for this search query to the estimated cost of purchasing the same number of targeted visitors coming to this URL
    # * Nr - The number of search results - how many pages does Google know for this query
    # * Td - Dynamics of change in the number of search queries in the past 12 months (estimated)
    def keywords_organic params = {}
      url? ? request(params.merge(:report_type => :url_organic)) : request(params.merge(:report_type => :domain_organic))
    end

    # AdWords keywords report
    # Can be called for a domain or a URL.
    # Default columns for a domain:
    # * Ph - Search query which the site buys in AdWords in Google
    # * Po - The position of the ad at the time of data collection
    # * Pp - The position of the ad at the time of previous data collection
    # * Nq - Average number of queries of this keyword in a month, for the corresponding local version of Google
    # * Cp - Average price of a click on the AdWords ad for this search query, in U.S. dollars
    # * Vu - Display URL. This is the URL displayed on your ad to identify your site to users.
    # * Tr - The ratio of the number of visitors coming to the site from this ad to all visitors coming from Google AdWords
    # * Tc - The ratio of site's expenditures on this particular ad to it's expenditures on all AdWords ads in general
    # * Co - Competition of advertisers in AdWords for that term, the higher is the number - the higher is the competition
    # * Nr - The number of search results - how many pages does Google know for this query
    # * Td - Dynamics of change in the number of search queries in the past 12 months (estimated)
    # * Ur - The destination URL is the exact URL within your website that you want to send users to from your ad.
    # Default columns for a URL:
    # * Ph - Search query that the URL has within the first 20 Google Organic or AdWords results
    # * Po - The position of this URL for this keyword in Organic or AdWords results
    # * Nq - Average number of queries of this keyword in a month, for the corresponding local version of Google
    # * Cp - Average price of a click on the AdWords ad for this search query, in U.S. dollars
    # * Co - Competition of advertisers in AdWords for that term, the higher is the number - the higher is the competition
    # * Tr - The ratio of the number of visitors coming to the URL from this keyword to all visitors coming
    # * Tc - The ratio of the estimated cost of buying the same number of visitors for this search query to the estimated cost of purchasing the same number of targeted visitors coming to this URL
    # * Nr - The number of search results - how many pages does Google know for this query
    # * Td - Dynamics of change in the number of search queries in the past 12 months (estimated)
    def keywords_adwords params = {}
      url? ? request(params.merge(:report_type => :url_adwords)) : request(params.merge(:report_type => :domain_adwords))
    end

    # Competitors in organic search report
    # Default columns:
    # * Dn - Sites competing with this site in Google search results, sorted by the number of common keywords
    # * Np - The number of keywords on which the site is displayed in search results next to the analyzed site
    # * Or - Keywords that this site has in TOP20 Google Organic results
    # * Ot - Estimated number of visitors coming from the first 20 Google search results (per month)
    # * Oc - Estimated cost of purchasing the same number of visitors
    # * Ad - Keywords that this site has in TOP20 Google AdWords
    def competitors_organic params = {}
      request(params.merge(:report_type => :domain_organic_organic))
    end

    # Competitors in AdWords search report
    # Default columns:
    # * Dn - Sites competing with this site in AdWords, sorted by the number of common keywords
    # * Np - Number of common keywords in AdWords that these two sites buy
    # * Ad - Keywords that this site has in TOP20 Google AdWords
    # * At - Estimated number of visitors coming from AdWords (per month)
    # * Ac - Estimated expenses of the site for the advertising in AdWords (per month)
    # * Or - Keywords that this site has in TOP20 Google Organic results
    def competitors_adwords params = {}
      request(params.merge(:report_type => :domain_adwords_adwords))
    end

    # Potential ad/traffic buyers report
    # Default columns:
    # * Dn - The list of sites that buys ads in AdWords for those keywords that the domain under analyzis has within Google TOP20
    # * Np - Number of keywords on which ads of this particular site appear and the analyzed site gets within Google TOP20
    # * Ad - Keywords that this site has in TOP20 Google AdWords
    # * At - Estimated number of visitors coming from AdWords (per month)
    # * Ac - Estimated expenses of the site for the advertising in AdWords (per month)
    # * Or - Keywords that this site has in TOP20 Google Organic results
    def competitors_organic_by_adwords params = {}
      request(params.merge(:report_type => :domain_organic_adwords))
    end

    # Potential ad/traffic sellers report
    # Default columns:
    # * Dn - Sites that get into Google TOP20 for keyword queries that analyzed site buy in AdWords
    # * Np - The number of keywords which this site has in search results next to the AdWords ads of the analyzed site
    # * Or - Keywords that this site has in TOP20 Google Organic results
    # * Ot - Estimated number of visitors coming from the first 20 Google search results (per month)
    # * Oc - Estimated cost of purchasing the same number of visitors
    # * Ad - Keywords that this site has in TOP20 Google AdWords
    def competitors_adwords_by_organic params = {}
      request(params.merge(:report_type => :domain_adwords_organic))
    end

    # Related keyword report
    # Default columns:
    # * Ph - The search query which the site has within the first 20 Google search results
    # * Nq - Average number of queries of this keyword in a month, for the corresponding local version of Google
    # * Cp - Average price of a click on the AdWords ad for this search query, in U.S. dollars
    # * Co - Competition of advertisers in AdWords for that term, the higher is the number - the higher is the competition
    # * Nr - The number of search results - how many pages does Google know for this query
    # * Td - Dynamics of change in the number of search queries in the past 12 months (estimated)
    def related params = {}
      request(params.merge(:report_type => :phrase_related))
    end

    private

    def request params = {}
      validate_parameters params
      temp_url = "#{API_REPORT_URL}" #do not copy the constant as is or else the constant would be modified !!
      @parameters.each {|k, v|
        if v.blank?
          temp_url.gsub!(/&[^&=]+=%#{k.to_s}%/i, '')
        else
          temp_url.gsub!("%#{k.to_s.upcase}%", URI.escape(v.to_s).gsub('&', '%26'))
        end
      }
      puts "[Semrush query] URL: #{temp_url}" if Semrush.debug
      url = URI.parse(temp_url)
      Semrush.before.call(@parameters.merge(:url => url))
      response = Net::HTTP.start(url.host, url.port) {|http|
        http.get(url.path+"?"+url.query)
      }.body rescue "ERROR :: RESPONSE ERROR (-1)" # Make this error up
      response.force_encoding("utf-8")
      output = response.starts_with?("ERROR") ? error(response) : parse(response)
      Semrush.after.call(@parameters.merge(:url => url), output)
      output
    end

    # All parameters:
    # * db - requested database
    # * report_type - type of the report
    # * api_key - user identification key, you can find it in your profile on the Semrush site
    # * request_type - type of the request.
    # * request - your request
    # * limit - number of results returned
    # * offset - says to skip that many results before beginning to return results to you
    # * export_columns - list of column names, separated by coma. You may list just the column names you need in an order you need.
    #
    # more details in http://www.semrush.com/api.html
    def validate_parameters params = {}
      params.symbolize_keys!
      params.delete(:db) unless DBS.include?(params[:db].try(:to_sym))
      params.delete(:report_type) unless REPORT_TYPES.include?(params[:report_type].try(:to_sym))
      params.delete(:request_type) unless REQUEST_TYPES.include?(params[:request_type].try(:to_sym))
      @parameters = {:db => "us", :api_key => Semrush.api_key, :limit => "", :offset => "", :export_columns => ""}.merge(@parameters).merge(params)
      raise Semrush::Exception::Nolimit.new(self, "The limit parameter is missing: a limit is required.") unless @parameters[:limit].present? && @parameters[:limit].to_i>0
      raise Semrush::Exception::BadArgument.new(self, "Request parameter is missing: Domain name, URL, or keywords are required.") unless @parameters[:request].present?
      raise Semrush::Exception::BadArgument.new(self, "Bad db: #{@parameters[:db]}") unless DBS.include?(@parameters[:db].try(:to_sym))
      raise Semrush::Exception::BadArgument.new(self, "Bad report type: #{@parameters[:report_type]}") unless REPORT_TYPES.include?(@parameters[:report_type].try(:to_sym))
      raise Semrush::Exception::BadArgument.new(self, "Bad request type: #{@parameters[:request_type]}") unless REQUEST_TYPES.include?(@parameters[:request_type].try(:to_sym))
    end

    # Format and raise an error
    def error(text = "")
      e = /ERROR\s(\d+)\s::\s(.*)/.match(text) || {}
      name = (e[2] || "UnknownError").titleize
      code = e[1] || -1
      error_class = name.gsub(/\s/, "")

      if error_class == "NothingFound"
        []
      else
        begin
          raise Semrush::Exception.const_get(error_class).new(self, "#{name} (#{code})")
        rescue
          raise Semrush::Exception::Base.new(self, "#{name} (#{code}) *** error_class=#{error_class} not implemented ***")
        end
      end
    end

    def parse(text = "")
      csv = CSV.parse(text.to_s, :col_sep => ";")
      data = {}
      format_key = lambda do |k|
        r = {
          /\s/ => "_",
          /[|\.|\)|\(]/ => "",
          /%/ => "percent",
          /\*/ => "times"
        }
        k = k.to_s.downcase
        r.each_pair {|pattern, replace| k.gsub!(pattern, replace) }
        k.to_sym
      end

      # (thanks http://snippets.dzone.com/posts/show/3899)
      keys = csv.shift.map(&format_key)
      string_data = csv.map {|row| row.map {|cell| cell.to_s } }
      string_data.map {|row| Hash[*keys.zip(row).flatten] }
    rescue CSV::MalformedCSVError => csvife
      tries ||= 0
      if (tries += 1) < 3
        retry
      else
        raise CSV::MalformedCSVError.new("Bad format for CSV: #{text.inspect}").tap{|e|
          e.set_backtrace(csvife.backtrace)}
      end
    end

    def domain?
      @parameters[:request_type].present? && REQUEST_TYPES.include?(@parameters[:request_type].to_sym) && @parameters[:request_type].to_sym==:domain
    end
    def url?
      @parameters[:request_type].present? && REQUEST_TYPES.include?(@parameters[:request_type].to_sym) && @parameters[:request_type].to_sym==:url
    end
    def phrase?
      @parameters[:request_type].present? && REQUEST_TYPES.include?(@parameters[:request_type].to_sym) && @parameters[:request_type].to_sym==:phrase
    end


  end
end