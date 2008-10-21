require File.dirname(__FILE__)+'/'+'../../src/command/command_parser.rb'

describe CommandParser do
  before(:each) do
    @parser=CommandParser.new
  end
  it 'should have context property' do
    @parser.context.kind_of?(CommandContext).should be_true
  end
  it 'should error when define_command called with no block' do
    lambda{@parser.define_command('hage')}.should raise_error(ArgumentError)
  end
  it 'should define command with no args by define_command' do
    called=false
    @parser.define_command('the_command') do
      called=true
      100
    end
    called.should be_false
    @parser.exec('the_command').should be == 100
    called.should be_true
  end
  it 'should define command with one string argument by define_command' do
    pending 'later'
    @parser.define_command('command',[[:string_arg,String]]) do
      @string_arg
    end
    @parser.exec('command hoge').should be == 'hoge'
  end
  it 'should validate command count on exec' do
    pending 'later'
  end
end
