require 'spec_helper'

describe "Reports:" do
  before(:all) do #once (and could be modified by the following tests)
     Semrush.config do |config|
      config.api_key = API_KEY
        config.debug = true
    end
  end

  describe Semrush, "running basic reports" do
    it "works with the root method 'domain_rank'" do
      lambda{Semrush::Report.new.domain_rank(:request_type => :domain, :request => "seobook.com", :db => :us, :limit => 5)}.should_not raise_error
    end
  end

  describe Semrush, "running domain reports" do
    it "initializes correctly" do
      lambda{Semrush::Report.domain("seobook.com", :db => :us)}.should_not raise_error
    end
    it "initializes correctly with params" do
      lambda{Semrush::Report.domain("seobook.com", :db => :us)}.should_not raise_error
    end
    [:basics, :organic, :adwords].each do |method|
      it "works with the method '#{method}'" do
        lambda{@parsed = Semrush::Report.domain("seobook.com").send(method, :db => :us, :limit => 5)}.should_not raise_error
        @parsed.should_not be_nil
        @parsed.should be_a_kind_of(Array)
        @parsed.first.should be_a_kind_of(Hash) if !@parsed.first.nil?
      end
    end

  end

  describe Semrush, "running url reports" do
    it "initializes correctly" do
      lambda{Semrush::Report.url("http://tools.seobook.com/", :db => :us)}.should_not raise_error
    end
    it "initializes correctly with params" do
      lambda{Semrush::Report.url("http://tools.seobook.com/", :db => :us)}.should_not raise_error
    end
    [:organic, :adwords].each do |method|
      it "works with the method '#{method}'" do
        lambda{@parsed = Semrush::Report.url("http://tools.seobook.com/").send(method, :db => :us, :limit => 5)}.should_not raise_error
        @parsed.should_not be_nil
        @parsed.should be_a_kind_of(Array)
        @parsed.first.should be_a_kind_of(Hash) if !@parsed.first.nil?
      end
    end
    [:basics, :competitors_organic, :competitors_adwords, :competitors_organic_by_adwords, :competitors_adwords_by_organic].each do |method|
      it "should not work with the method '#{method}'" do
        lambda{@parsed = Semrush::Report.url("http://tools.seobook.com/").send(method, :db => :us, :limit => 5)}.should raise_error
      end
    end
  end

  describe Semrush, "running phrase reports" do
    it "initializes correctly" do
      lambda{Semrush::Report.phrase("search+engine+optimization", :db => :us)}.should_not raise_error
      Semrush::Report.phrase("zazazadsskhsqengineazazaoptimization", :db => :us, :limit => 1).organic.count.should == 0
    end
    it "initializes correctly with params" do
      lambda{Semrush::Report.phrase("search+engine+optimization", :db => :us)}.should_not raise_error
    end
    [:basics, :related, :organic, :fullsearch].each do |method|
      it "works with the method '#{method}'" do
        lambda{@parsed = Semrush::Report.phrase("search+engine+optimization").send(method, :db => :us, :limit => 5)}.should_not raise_error
        @parsed.should_not be_nil
        @parsed.should be_a_kind_of(Array)
        @parsed.count.should > 0
        @parsed.first.should be_a_kind_of(Hash) if !@parsed.first.nil?
      end
    end
    [:basics, :related].each do |method|
      it "deals correctly with & in phrase" do
        lambda{Semrush::Report.phrase("calvin & hobbs").send(method, :db => :us, :limit => 5)}.should_not raise_error
      end
    end
    [:basics].each do |method|
      it "accepts a display date parameter" do
        lambda{Semrush::Report.phrase("calvin & hobbs").send(method, :db => :us, :limit => 5, :display_date => Date.today.strftime('%Y%m%d'))}.should_not raise_error
      end
    end
  end

  describe Semrush, "parameters positions in reports" do
    it "could be set in the class method" do
      lambda{Semrush::Report.domain("seobook.com", :db => :fr, :limit => 5, :offset => 2)}.should_not raise_error
    end
    it "could be set in the instance method" do
      lambda{Semrush::Report.domain("seobook.com").organic(:db => :fr, :limit => 5, :offset => 2)}.should_not raise_error
    end
    it "both methods get the same results" do
      in_class = Semrush::Report.domain("seobook.com", :db => :fr, :limit => 5, :offset => 2).organic
      in_object = Semrush::Report.domain("seobook.com").organic(:db => :fr, :limit => 5, :offset => 2)
      in_class.should == in_object
    end
  end

  describe Semrush, "using display_sort parameter" do
    it "works with domain_organic" do
      lambda{Semrush::Report.domain("wikipedia.org", :limit => 5, :display_sort => 'tr_asc').organic}.should_not raise_error
    end
  end
  describe Semrush, "using display_filter parameter" do
    it "returns an Array with elements if Po<5" do
      r = Semrush::Report.domain("wikipedia.org", :limit => 5, :display_filter => '+|Po|Lt|5').organic
      r.should be_a_kind_of Array
      r.count.should > 0
    end
    it "returns empty Array if Po<1" do
      Semrush::Report.domain("wikipedia.org", :limit => 5, :display_filter => '+|Po|Lt|1').organic.should == []
    end
  end

end
