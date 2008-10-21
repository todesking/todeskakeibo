describe TypeParser,'by default' do
  before(:each) do
    @context=CommandContext.new
    @tp=TypeParser.new
  end
  it 'should error when parse with unsupported type' do
    lambda{@tp.parse('hage',Object)}.should raise_error(ArgumentError)
  end
  it 'should parse string argument by default' do
    @tp.parse('this is string',String).should be == 'this is string'
  end
  it 'should parse numeric argument by default' do
    @tp.parse('100',Numeric).should be == 100
  end
  it 'should parse date argument as yyyymmdd by default' do
    @tp.parse('20081011',Date).should be == Date.new(2008,10,11)
  end
  it 'should error when unknown date format' do
    lambda{@tp.parse('200801010')}.should raise_error(ArgumentError)
  end
end

