require File.dirname(__FILE__)+'/'+'../../src/util/relative_date_parser.rb'

describe RelativeDateParser do
  before(:each) do
    @rdp=RelativeDateParser.new
  end
  it 'should can set base date' do
    @rdp.base_date=Date.new #only check no-error
  end
  it 'should parse date from yyyymmdd string' do
    @rdp.date('20081020').should be == Date.new(2008,10,20)
  end
  it 'should parse date based on base_date' do
    @rdp.base_date=Date.new(2008,10,10)
    @rdp.date('1001').should be == Date.new(2008,10,1)
    @rdp.date('01').should be == Date.new(2008,10,1)
    @rdp.date('1').should be == Date.new(2008,10,1)
  end
end
