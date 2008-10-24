require File.dirname(__FILE__)+'/'+'../../src/util/relative_date_parser.rb'

describe RelativeDateParser do
  before(:each) do
    @rdp=RelativeDateParser.new
  end
  it 'should can set base date' do
    @rdp.base_date=Date.new #only check no-error
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
    @rdp.parse('today').should be == Date.today
  end
  it 'should parse "yesterday"' do
    @rdp.parse('yesterday').should be == Date.today - 1
  end
  it 'should parse "d-n" format' do
    @rdp.parse('d-1').should == @rdp.parse('yesterday')
    @rdp.parse('d-3').should == Date.today - 3
  end
  it 'should error when unknown format' do
    lambda{ @rdp.parse('yesterdayyy') }.should raise_error(ArgumentError)
    lambda{ @rdp.parse('todayyy') }.should raise_error(ArgumentError)
  end
end
