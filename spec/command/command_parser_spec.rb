require File.dirname(__FILE__)+'/'+'../../src/command/command_parser.rb'

describe CommandParser,'#define_command and #exec' do
  before(:each) do
    @parser=CommandParser.new
  end

  it 'should error when overwriting existing command' do
    pending
  end

  it 'should error when define_command called with no block' do
    lambda{@parser.define_command('hage')}.should raise_error(ArgumentError)
  end

  it 'should error when undefined command executed' do
    lambda{@parser.exec('hage')}.should raise_error(ArgumentError)
  end

  it 'should error when command executed with wrong number of arguments' do
    @parser.define_command('command',[[:string_arg,String]]) do
      @string_arg
    end
    lambda{@parser.exec('command')}.should raise_error(ArgumentError)
    lambda{@parser.exec('command hoge hage')}.should raise_error(ArgumentError)
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
    @parser.define_command('command',[[:string_arg,String]]) do
      @string_arg
    end
    @parser.exec('command hoge').should be == 'hoge'
  end

  it 'should execute command with multiple arguments' do
    @parser.define_command('transaction',[[:date,Date],[:from,String],[:to,String],[:amount,Numeric]]) do
      [@date,@from,@to,@amount]
    end
    @parser.exec('transaction 20081011 bank wallet 20000').should be == [Date.new(2008,10,11),'bank','wallet',20000]
  end
end
describe CommandParser,'#define_alias' do
  before(:each) do
    @parser=CommandParser.new
  end

  it 'should error when overwriting existing alias' do
    pending
  end

  it 'should define alias for command' do
    @parser.define_command('transaction',[]) do
      'transaction'
    end
    @parser.define_alias('t','transaction')
    @parser.exec('t').should be == 'transaction'
  end

  it 'should error when defining alias for undefined command' do
    pending
  end
end
