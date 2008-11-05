require File.dirname(__FILE__)+'/'+'../../src/util/date_parser.rb'

describe DateParser do
  before(:each) do
    @rdp=DateParser.new
    def @rdp.today
      Date.new(2008,10,10)
    end
  end
  it 'should can set base date' do
    @rdp.base_date=Date.new #only check no-error
  end
  it 'should start_of_month == 1 by default' do
    @rdp.start_of_month.should == 1
  end
  it 'should parse date from yyyymmdd string' do
    @rdp.parse('20081020').should be == Date.new(2008,10,20)
  end
  it 'should parse date based on base_date' do
    @rdp.base_date=Date.new(2008,10,10)
    @rdp.parse('1001').should be == Date.new(2008,10,1)
    @rdp.parse('02').should be == Date.new(2008,10,2)
    @rdp.parse('3').should be == Date.new(2008,10,3)
  end
  it 'should parse "today"' do
    @rdp.parse('today').should be == Date.new(2008,10,10)
  end
  it 'should parse "yesterday"' do
    @rdp.parse('yesterday').should be == Date.new(2008,10,10)-1
  end
  it 'should parse "d-n" format' do
    @rdp.parse('d-1').should == @rdp.parse('yesterday')
    @rdp.parse('d-3').should == @rdp.parse('today')-3
  end
  it 'should error when unknown format' do
    lambda{ @rdp.parse('yesterdayyy') }.should raise_error(ArgumentError)
    lambda{ @rdp.parse('todayyy') }.should raise_error(ArgumentError)
  end
end

describe DateParser,'around date range' do
  before(:each) do
    @rdp=DateParser.new
    @rdp.base_date=Date.new(2008,10,1)
    def @rdp.today
      Date.new(2008,10,10)
    end
  end
  def d(y,m,d); Date.new(y,m,d); end
  it 'should parse start-end syntax' do
    @rdp.parse_range('10-20').should == (d(2008,10,10)..d(2008,10,20))
  end
  it 'should parse from month' do
    @rdp.parse_range('10').should == (d(2008,10,1)..d(2008,10,31))
    @rdp.parse_range('9').should == (d(2008,9,1)..d(2008,9,30))
  end
  it 'should parse from year' do
    @rdp.parse_range('2008').should == (d(2008,1,1)..d(2008,12,31))
  end
  it 'should parse from month name' do
    @rdp.parse_range('dec').should == (d(2008,12,1)..d(2008,12,31))
    @rdp.parse_range('Nov').should == (d(2008,11,1)..d(2008,11,30))
  end
  it 'should affected by #start_of_month' do
    @rdp.start_of_month=1
    @rdp.parse_range('dec').should == (d(2008,12,1)..d(2008,12,31))
    @rdp.start_of_month=15
    @rdp.parse_range('dec').should == (d(2008,12,15)..d(2009,1,14))
    @rdp.parse_range('1010-1012').should == (d(2008,10,10)..d(2008,10,12))
  end
  it 'should parse relative range format' do
    @rdp.parse_range('3d').should == (d(2008,10,8)..d(2008,10,10))
    @rdp.parse_range('2m').should == (d(2008,8,10)..d(2008,10,10))
  end
  it 'should error when invalid string passed' do
    lambda{ @rdp.parse_range('10000')}.should raise_error(ArgumentError)
    lambda{ @rdp.parse_range('Foo')}.should raise_error(ArgumentError)
  end
end
