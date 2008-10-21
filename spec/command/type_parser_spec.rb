describe TypeParser,'by default' do
  before(:each) do
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
    lambda{@tp.parse('200801010',Date)}.should raise_error(ArgumentError)
  end
end

describe TypeParser,'#define_mapping' do
  before(:each) do
    @tp=TypeParser.new
  end
  it 'should define new mapping' do
    lambda{@tp.parse('1.0',Float)}.should raise_error(ArgumentError)
    @tp.define_mapping(Float) {|str| str.to_f}
    @tp.parse('1.0',Float).should be == '1.0'.to_f
  end
end
