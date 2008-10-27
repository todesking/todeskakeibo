require File.join(File.dirname(__FILE__),'../../src/util/helper.rb')

describe Helper do
  it '.create_date_range should create date range from year,month,date' do
    Helper.create_date_range(2008).should == (Date.new(2008,1,1)..Date.new(2008,12,31))
    Helper.create_date_range(2008,10).should == (Date.new(2008,10,1)..Date.new(2008,10,31))
    Helper.create_date_range(2008,10,1).should == (Date.new(2008,10,1)..Date.new(2008,10,1))
  end
  it '.create_date_range should error when year=nil' do
    lambda { Helper.create_date_range(nil) }.should raise_error(ArgumentError)
  end
end
