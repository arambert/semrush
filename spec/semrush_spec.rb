require 'spec_helper'

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
      lambda{Semrush::Report.domain("seobook.com", :db => :us).organic(:limit => 5)}.should_not raise_error
    end
  end

end