= Semrush

Semrush is a ruby wrapper for the SEMRush API.

== Requirements

- Ruby 1.9
- ActiveSupport (tested with ActiveSupport 3.1 & 3.2)

== Installation

Add the gem to your Gemfile:

  gem install semrush

Create an initializer, for instance semrush.rb with the following:

  Semrush.config do |config|
    config.api_key = "7899esf6874"
  end

Replace '7899esf6874' with your SEMRush api key.

You may also use the following parameters in config:

  config.before = lambda{|params| puts params}            # (Proc or lambda) will be called before the call to SemRush (even if this return false it still runs the request)
  config.after  = lambda{|params, results| puts results}  # (Proc or lambda) will be called after the call to SemRush (if the call returns an exception, this will not be executed)

== Getting started

First, create a report for a domain, a URL or a phrase with:

  report = Semrush::Report.domain("seobook.com")                 # for the "seobook.com" domain
  report = Semrush::Report.url("http://tools.seobook.com/")      # for the "http://tools.seobook.com/" url
  report = Semrush::Report.phrase("search+engine+optimization")  # for the "search+engine+optimization" phrase

Then run the report type you need:

  basic_data = report.basics

or

  keywords_data = report.keywords_organic

If you want to know your remaining api units:

  units = Semrush::Report.remaining_quota


== Parameters

You may use the following parameters:

  :db         # (String) select the google engine ('us' for google.com 'fr' for google.fr)
  :api_key    # (String) change the api_key
  :limit      # (Integer) select only the first 'limit' entries (This parameter is required in order to avoid uncontrolled heavy usage)
  :offset     # (Integer) skip the first 'offset' entries
  :export_columns # (String) select the columns you want to fetch, for instance: :export_columns => "Dn,Rk"
  :display_sort   # (String) select the column and the order you want to sort with, for instance: :display_sort => 'tr_asc'
  :display_filter # (String) list of filters for the report, separated by '|' (maximum number - 25). A filter consists of <sign>|<field>|<operation>|<value> (read http://www.semrush.com/api), for instance: :display_filter => '+|Po|Lt|5'
  :display_date	  # (String) select the date for the report data, in the format: YYYYMM15

Some examples:

  report = Semrush::Report.domain("seobook.com", :db => 'us', :limit => 100)
  data = report.basics

or

  report = Semrush::Report.domain("seobook.com")
  data = report.basics(:db => 'us', :limit => 100)

You will find more information about these parameters at http://www.semrush.com/api.html

== Reports

=== Source of reports

They are 3 sources for the reports: domain, url and phrase.

  report = Semrush::Report.domain("seobook.com")                 # for the "seobook.com" domain
  report = Semrush::Report.url("http://tools.seobook.com/")      # for the "http://tools.seobook.com/" url
  report = Semrush::Report.phrase("search+engine+optimization")  # for the "search+engine+optimization" phrase

=== Report types

You may call for one of the following report types:

  data = report.basics                          # main report for either a domain or a phrase
  data = report.organic                         # organic report for either a domain, a URL or a phrase
  data = report.adwords                         # adwords report for either a domain or a URL
  data = report.competitors_organic             # for a domain
  data = report.competitors_adwords             # for a domain
  data = report.competitors_organic_by_adwords  # for a domain
  data = report.competitors_adwords_by_organic  # for a domain
  data = report.related                         # keywords related report for a phrase
  data = report.fullsearch                      # phrase fullsearch report
  data = report.history_adwords                 # ads history for either a domain or a phrase

For more information about the report types, please read http://www.semrush.com/api.html

== ChangeLog

=== 3.0.18, 2014-10-03

* Add new databases (countries)

=== 3.0.17, 2014-08-01

* Remove Pony dependency

=== 3.0.16, 2014-07-21

* Add support for fullsearch reports
* Add support for Adwords history reports

=== 3.0.15, 2013-06-26

* activesupport dependency to >= 3.2.0 to support rails 4

=== 3.0.14, 2013-06-10

* parameter 'display_filter' has to be url-encoded in a separate way

=== 3.0.13, 2013-06-10

* Add report type 'phrase_oganic'
* Add parameter 'display_sort'
* Add parameter 'display_filter'

=== 3.0.12, 2013-05-31

* Force parameter 'limit' > 0 to prevent limit=0

=== 3.0.11, 2013-05-22

* Fix parameters accessible through Semrush.before & Semrush.after

=== 3.0.10, 2013-05-21

* Fix remaining_quota (problem with redirections)

=== 3.0.9, 2013-05-21

* Add url in parameters accessible through Semrush.before & Semrush.after

=== 3.0.8, 2013-05-21

* Move after & before callbacks to Semrush module: Semrush.before & Semrush.after

=== 3.0.7, 2013-05-21

* Add after & before callbacks

=== 3.0.6, 2013-05-7

* Add method remaining_quota

== About authors

This gem is inspired by the work of Cramer Development for the semrush-client plugin (https://github.com/cramerdev/semrush-client).

It has been rewritten and gemified for the internal use in Weboglobin (http://fr.weboglobin.com).

This project rocks and uses MIT-LICENSE.
