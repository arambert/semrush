require 'spec_helper'
API_KEY = ENV['API_KEY'] || "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"

describe Semrush, "config" do
  it "comes from a module" do #simple test to init tests
    Semrush.should be_a_kind_of(Module)
  end
  it "throws an error if no api key" do
    lambda{
      Semrush.config do |config|
        config.api_key = nil
      end
    }.should raise_error(Semrush::Exception::BadApiKey)
  end
end
describe "Requests:" do
  before(:all) do #once (and could be modified by the following tests)
     Semrush.config do |config|
      config.api_key = API_KEY
        config.debug = true
    end
  end  

  describe Semrush, "get remaining_quota" do
    it "works when calling remaining_quota" do
      lambda{Semrush::Report.remaining_quota}.should_not raise_error
    end
    it "gets remaining_quota as an integer" do
      q = Semrush::Report.remaining_quota
      puts "remaining_quota: #{q}"
      q.should be_a_kind_of(Integer)
    end
  end

  describe Semrush, "running basic reports" do
    it "works with the root method 'domain_rank'" do
      lambda{Semrush::Report.new.domain_rank(:request_type => :domain, :request => "seobook.com", :db => :us, :limit => 5)}.should_not raise_error
    end
  end

  describe Semrush, "log reports with before & after" do
    before(:all) do #once (and could be modified by the following tests)
      Semrush.config do |config|
        config.api_key = API_KEY
        config.debug = true
        config.before = lambda{|params| puts params}
        config.after = lambda{|params, results| puts results}
      end
    end  
    it "works" do
      lambda{Semrush::Report.domain("seobook.com", :db => :us).keywords_organic(:limit => 5)}.should_not raise_error
    end
  end

  describe Semrush, "running domain reports" do
    it "initializes correctly" do
      lambda{Semrush::Report.domain("seobook.com", :db => :us)}.should_not raise_error
    end
    it "initializes correctly with params" do
      lambda{Semrush::Report.domain("seobook.com", :db => :us)}.should_not raise_error
    end
    [:basics, :keywords_organic, :keywords_adwords].each do |method|
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
    [:keywords_organic, :keywords_adwords].each do |method|
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
    end
    it "initializes correctly with params" do
      lambda{Semrush::Report.phrase("search+engine+optimization", :db => :us)}.should_not raise_error
    end
    [:basics, :related].each do |method|
      it "works with the method '#{method}'" do
        lambda{@parsed = Semrush::Report.phrase("search+engine+optimization").send(method, :db => :us, :limit => 5)}.should_not raise_error
        @parsed.should_not be_nil
        @parsed.should be_a_kind_of(Array)
        @parsed.first.should be_a_kind_of(Hash) if !@parsed.first.nil?
      end
    end
    [:basics, :related].each do |method|
      it "deals correctly with & in phrase" do
        lambda{Semrush::Report.phrase("calvin & hobbs").send(method, :db => :us, :limit => 5)}.should_not raise_error
      end
    end
  end

  describe Semrush, "parameters in reports" do
    it "could be set in the class method" do
      lambda{Semrush::Report.domain("seobook.com", :db => :fr, :limit => 5, :offset => 2)}.should_not raise_error
    end
    it "could be set in the instance method" do
      lambda{Semrush::Report.domain("seobook.com").keywords_organic(:db => :fr, :limit => 5, :offset => 2)}.should_not raise_error
    end
    it "both methods get the same results" do
      in_class = Semrush::Report.domain("seobook.com", :db => :fr, :limit => 5, :offset => 2).keywords_organic
      in_object = Semrush::Report.domain("seobook.com").keywords_organic(:db => :fr, :limit => 5, :offset => 2)
      in_class.should == in_object
    end

  end
end