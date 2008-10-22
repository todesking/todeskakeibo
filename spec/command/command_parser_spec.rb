require File.dirname(__FILE__)+'/'+'../../src/command/command_parser.rb'

describe CommandParser,'#command' do
  before(:each) do
    @parser=CommandParser.new
    @parser.define_command('command_1',[]){}
  end
  it 'should return Command object from command name' do
    @parser.command('command_1').should_not be_nil
    @parser.command('undefined').should be_nil
  end
end

describe CommandParser,'#define_command and #execute' do
  before(:each) do
    @parser=CommandParser.new
  end

  it 'should error when overwriting existing command' do
    @parser.define_command('hage',[]){}
    lambda{@parser.define_command('hage',[]){}}.should raise_error(ArgumentError)
  end

  it 'should error when define_command called with no block' do
    lambda{@parser.define_command('hage')}.should raise_error(ArgumentError)
  end

  it 'should error when undefined command executed' do
    lambda{@parser.execute('hage')}.should raise_error(ArgumentError)
  end

  it 'should error when command executed with wrong number of arguments' do
    @parser.define_command('command',[[:string_arg,String]]) do
      @string_arg
    end
    lambda{@parser.execute('command')}.should raise_error(ArgumentError)
    lambda{@parser.execute('command hoge hage')}.should raise_error(ArgumentError)
  end

  it 'should define command with no args by define_command' do
    called=false
    @parser.define_command('the_command') do
      called=true
      100
    end
    called.should be_false
    @parser.execute('the_command').should be == 100
    called.should be_true
  end

  it 'should define command with one string argument by define_command' do
    @parser.define_command('command',[[:string_arg,String]]) do
      @string_arg
    end
    @parser.execute('command hoge').should be == 'hoge'
  end

  it 'should execute command with multiple arguments' do
    @parser.define_command('transaction',[[:date,Date],[:from,String],[:to,String],[:amount,Numeric]]) do
      [@date,@from,@to,@amount]
    end
    @parser.execute('transaction 20081011 bank wallet 20000').should be == [Date.new(2008,10,11),'bank','wallet',20000]
  end
end
describe CommandParser,'#define_alias' do
  before(:each) do
    @parser=CommandParser.new
  end

  it 'should error when overwriting existing alias' do
    @parser.define_command('foo',[]){}
    @parser.define_alias('f','foo')
    lambda{@parser.define_alias('f','foo')}.should raise_error(ArgumentError)
  end

  it 'should define alias for command' do
    @parser.define_command('transaction',[]) do
    end
    @parser.define_alias('t','transaction')
    @parser.command('t').should be == @parser.command('transaction')
    @parser.command('t').name.should be == 'transaction'
  end

  it 'should error when defining alias for undefined command' do
    lambda{@parser.define_alias('f','foo')}.should raise_error(ArgumentError)
  end
end
