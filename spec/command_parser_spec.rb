require File.dirname(__FILE__)+'/'+'../src/command_parser.rb'

describe CommandParser do
  before(:each) do
    @parser=CommandParser.new
  end
  it 'should have context property' do
    @parser.context.kind_of?(CommandContext).should be_true
  end
  it 'should define command by define_command' do
    called=false
    @parser.define_command('the_command') do
      called=true
      100
    end
    called.should be_false
    @parser.exec('the_command').should be == 100
    called.should be_true
  end
end
