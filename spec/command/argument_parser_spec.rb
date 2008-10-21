require File.dirname(__FILE__)+'/'+'../../src/command/argument_parser.rb'

describe ArgumentParser,'when construct' do
  it 'should raise error when initialize with wrong arguments' do
    lambda{ArgumentParser.new}.should raise_error(ArgumentError)
  end
  it 'should error when duplicated argument name' do
    lambda{ArgumentParser.new(CommandContext.new,[[:hoge,String],[:hage,Numeric],[:hoge,Date]])}.should raise_error(ArgumentError)
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

describe ArgumentParser,'#parse_argument' do
  before(:each) do
    @context=CommandContext.new
    @ap=ArgumentParser.new(@context,[ [:arg1,String], [:arg2,Numeric], [:arg3,Date] ])
  end
  it 'should error when parse with unsupported type' do
    lambda{@ap.parse_argument('hage',Object)}.should raise_error(ArgumentError)
  end
  it 'should parse string argument' do
    @ap.parse_argument('this is string',String).should be == 'this is string'
  end
  it 'should parse numeric argument' do
    @ap.parse_argument('100',Numeric).should be == 100
  end
  it 'should parse date from yyyymmdd string' do
    @ap.parse_argument('20081020',Date).should be == Date.new(2008,10,20)
  end
  it 'should parse date from mmdd/dd based on context' do
    @context.base_date=Date.new(2008,10,10)
    @ap.parse_argument('1001',Date).should be == Date.new(2008,10,1)
    @ap.parse_argument('01',Date).should be == Date.new(2008,10,1)
    @ap.parse_argument('1',Date).should be == Date.new(2008,10,1)
  end
  it 'should error when wrong date format passed' do
    lambda { @ap.parse_argument('totally-wrong',Date) }.should raise_error(ArgumentError)
    lambda { @ap.parse_argument('11299000900',Date) }.should raise_error(ArgumentError)
  end
end
describe ArgumentParser,'#parse' do
  before(:each) do
    @context=CommandContext.new
    @context.base_date=Date.new(2008,10,1)
    @ap=ArgumentParser.new(@context,[ [:arg1,String], [:arg2,Numeric], [:arg3,Date] ])
  end
  it 'should be parse arguments' do
    @ap.parse(['hoge','1000','1020']).should be == {:arg1 => 'hoge', :arg2 => 1000, :arg3 => Date.new(2008,10,20)}
  end
  it 'should error when invalid number of arguments' do
    lambda{@ap.parse(['hoge'])}.should raise_error(ArgumentError)
    lambda{@ap.parse([])}.should raise_error(ArgumentError)
    lambda{@ap.parse(['hoge','100','1220','fuba'])}.should raise_error(ArgumentError)
  end
end
