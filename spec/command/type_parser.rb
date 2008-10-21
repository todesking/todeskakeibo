describe TypeParser,'by default' do
  before(:each) do
    @context=CommandContext.new
    @tp=TypeParser.new
  end
  it 'should error when parse with unsupported type' do
    lambda{@tp.parse_argument('hage',Object)}.should raise_error(ArgumentError)
  end
  it 'should parse string argument by default' do
    @tp.parse_argument('this is string',String).should be == 'this is string'
  end
  it 'should parse numeric argument by default' do
    @tp.parse_argument('100',Numeric).should be == 100
  end
  it 'should parse date argument as yyyymmdd by default' do
    @tp.parse_argument('20081011',Date).should be == Date.new(2008,10,11)
  end
end
