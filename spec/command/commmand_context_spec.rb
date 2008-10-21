require File.dirname(__FILE__)+'/'+'../../src/command/command_context.rb'

describe CommandContext do
  before(:each) do
    @context=CommandContext.new
  end
  it 'should create date from yyyymmdd string' do
    @context.date('20081020').should be == Date.new(2008,10,20)
  end
  it 'should can specify base date' do
    @context.base_date=Date.new #only check no-error
  end
  it 'should create date from mmdd based on base_date' do
    @context.base_date=Date.new(2008,10,10)
    @context.date('1001').should be == Date.new(2008,10,1)
    @context.date('01').should be == Date.new(2008,10,1)
    @context.date('1').should be == Date.new(2008,10,1)
  end
  it 'should error when date called with wrong format passed' do
    lambda { @context.date('totally-wrong') }.should raise_error(ArgumentError)
    lambda { @context.date('11299000900') }.should raise_error(ArgumentError)
  end
end
