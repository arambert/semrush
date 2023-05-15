module Semrush
  # = Base Class for all Semrush API classes
  class Base
    def request params = {}
      validate_parameters params
      temp_url = "#{API_REPORT_URL}" #do not copy the constant as is or else the constant would be modified !!
      @parameters.each {|k, v|
        if v.blank?
          temp_url.gsub!(/&[^&=]+=%#{k.to_s}%/i, '')
        elsif k.to_sym==:display_filter
          temp_url.gsub!("%#{k.to_s.upcase}%", CGI.escape(v.to_s).gsub('&', '%26').gsub('+', '%2B'))
        else
          temp_url.gsub!("%#{k.to_s.upcase}%", CGI.escape(v.to_s).gsub('&', '%26'))
        end
      }
      puts "[Semrush query] URL: #{temp_url}" if Semrush.debug
      url = URI.parse(temp_url)
      Semrush.before.call(@parameters.merge(:url => url))
      response = Net::HTTP.start(url.host, url.port, :use_ssl => true) {|http|
        http.get(url.path+"?"+url.query)
      }.body rescue "ERROR :: RESPONSE ERROR (-1)" # Make this error up
      response.force_encoding("utf-8")
      output = response.starts_with?("ERROR") ? error(response) : parse(response)
      Semrush.after.call(@parameters.merge(:url => url), output)
      output
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
      return [] if text.empty?
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
      @parameters[:request_type].present? && @request_types.include?(@parameters[:request_type].to_sym) && @parameters[:request_type].to_sym==:domain
    end

    def url?
      @parameters[:request_type].present? && @request_types.include?(@parameters[:request_type].to_sym) && @parameters[:request_type].to_sym==:url
    end

    def phrase?
      @parameters[:request_type].present? && @request_types.include?(@parameters[:request_type].to_sym) && @parameters[:request_type].to_sym==:phrase
    end
  end
end
