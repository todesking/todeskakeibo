require File.dirname(__FILE__)+'/'+'../src/command_parser.rb'

describe CommandParser do
  before(:each) do
    @parser=CommandParser.new
  end
  it 'should have context property' do
    @parser.context.kind_of?(CommandContext).should be_true
  end
end
