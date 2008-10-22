require File.dirname(__FILE__)+'/'+'../../src/command/argument_parser.rb'
require File.dirname(__FILE__)+'/'+'../../src/command/type_parser.rb'

describe ArgumentParser,'when construct' do
  it 'should raise error when initialize with wrong arguments' do
    lambda{ArgumentParser.new}.should raise_error(ArgumentError)
  end
  it 'should error when duplicated argument name' do
    ArgumentParser.new(TypeParser.new,[[:hoge,String],[:hage,Numeric],[:moge,Date]]) #no error
    lambda{ArgumentParser.new(TypeParser.new,[[:hoge,String],[:hage,Numeric],[:hoge,Date]])}.should raise_error(ArgumentError)
  end
  it 'should error when argument with non default value is trailing' do
    lambda{ArgumentParser.new(@tp,[ [:arg1,Numeric,{:default=>100}], [:arg2,String] ])}.should raise_error(ArgumentError)
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

describe ArgumentParser,'#to_str' do
  def new_ap defs
    ArgumentParser.new(TypeParser.new,defs)
  end

  it 'should return human readable argument definition' do
    new_ap([]).to_str.should be == ''
    new_ap([ [:arg1,String] ]).to_str.should be == 'arg1:String'
    new_ap([ [:arg1,String], [:arg2,Date] ]).to_str.should be == 'arg1:String arg2:Date'
    new_ap([ [:arg1,String], [:arg2,Date,{:default=>nil}] ]).to_str.should be == 'arg1:String [arg2:Date]'
    new_ap([ [:arg1,String], [:arg2,Date,{:default=>nil}], [:arg3,Date,{:default=>nil}] ]).to_str.should be == 'arg1:String [arg2:Date] [arg3:Date]'
  end
end

describe ArgumentParser,'#parse' do
  before(:each) do
    tp=TypeParser.new
    @ap=ArgumentParser.new(tp,[ [:arg1,String], [:arg2,Numeric], [:arg3,Date] ])
  end
  it 'should be parse arguments' do
    @ap.parse(['hoge','1000','20081020']).should be == {:arg1 => 'hoge', :arg2 => 1000, :arg3 => Date.new(2008,10,20)}
  end
  it 'should error when invalid number of arguments' do
    lambda{@ap.parse(['hoge'])}.should raise_error(ArgumentError)
    lambda{@ap.parse([])}.should raise_error(ArgumentError)
    lambda{@ap.parse(['hoge','100','1220','fuba'])}.should raise_error(ArgumentError)
  end
end

describe ArgumentParser,'with variable argument definition' do
  before(:all) do
    @tp=TypeParser.new
  end

  it 'should parse default argument' do
    ap=ArgumentParser.new(@tp,[ [:arg1,Numeric], [:arg2,String,{:default=>'default'}] ])
    ap.parse(['10','20']).should be == {:arg1 => 10, :arg2 => '20'}
    ap.parse(['10']).should be == {:arg1 => 10, :arg2 => 'default'}
  end
  it 'should parse multiple default argument' do
    ap=ArgumentParser.new(@tp,[ [:arg1,Numeric,{:default=>100}], [:arg2,String,{:default=>'default'}] ])
    ap.parse(['10','20']).should be == {:arg1 => 10, :arg2 => '20'}
    ap.parse(['10']).should be == {:arg1 => 10, :arg2 => 'default'}
    ap.parse([]).should be == {:arg1=>100,:arg2=>'default'}
  end
end
