require File.dirname(__FILE__)+'/'+'../../src/command/argument_parser.rb'

describe ArgumentParser,'when construct' do
  it 'should raise error when initialize with wrong arguments' do
    lambda{ArgumentParser.new}.should raise_error(ArgumentError)
  end
end
describe ArgumentParser,'when no argument' do
  before(:each) do
    @context=CommandContext.new
    @ap=ArgumentParser.new(@context,[])
  end
  it 'should success when parse with right argument' do
    @ap.parse([]).should be == {}
  end
  it 'should error when parse with too long arguments' do
    lambda{@ap.parse(['hoge'])}.should raise_error(ArgumentError)
  end
end

describe ArgumentParser,'when some arguments' do
  before(:each) do
    @context=CommandContext.new
    @ap=ArgumentParser.new(@context,[ [:arg1,String], [:arg2,Numeric], [:arg3,Date] ])
  end
  it 'should parse string argument' do
    @ap.parse_argument('this is string',String).should be == 'this is string'
  end
  it 'should error when parse with unsupported type' do
    lambda{@ap.parse_argument('hage',Object)}.should raise_error(ArgumentError)
  end
  it 'should parse numeric argument' do
    @ap.parse_argument('100',Numeric).should be == 100
  end
end
