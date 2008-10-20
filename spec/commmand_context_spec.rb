require File.dirname(__FILE__)+'/'+'../src/command_context.rb'

describe CommandContext do
  before(:each) do
    @context=CommandContext.new
  end
  it 'should create date from yyyymmdd string' do
    @context.date('20081020').should be == Date.new(2008,10,20)
  end
end
