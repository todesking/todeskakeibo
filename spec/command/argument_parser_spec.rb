require File.dirname(__FILE__)+'/'+'../../src/command/argument_parser.rb'
require File.dirname(__FILE__)+'/'+'../../src/command/type_parser.rb'

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
    @ap=ArgumentParser.new(TypeParser.new,[])
  end
  it 'should success when parse with right argument' do
    @ap.parse([]).should be == {}
  end
  it 'should error when parse with too long arguments' do
    lambda{@ap.parse(['hoge'])}.should raise_error(ArgumentError)
  end
end

describe ArgumentParser,'#parse' do
  before(:each) do
    @context=CommandContext.new
    @context.base_date=Date.new(2008,10,1)
    tp=TypeParser.new
    tp.define_mapping(Date) {|str|
      @context.date(str)
    }
    @ap=ArgumentParser.new(tp,[ [:arg1,String], [:arg2,Numeric], [:arg3,Date] ])
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
