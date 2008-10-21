require File.dirname(__FILE__)+'/'+'../../src/command/command.rb'

describe Command,'when initialize' do
  it 'should error when no block given' do
    lambda{Command.new('hoge',ArgumentParser.new(CommandContext.new,[]))}.should raise_error(ArgumentError)
  end
end

describe Command,'with no arguments' do
  before(:each) do
    @context=CommandContext.new
    @command=Command.new('command',ArgumentParser.new(TypeParser.new,[])) do
      'command return value'
    end
  end
  it 'should raise error when arguments passed' do
    lambda{@command.exec('some arguments')}.should raise_error(ArgumentError)
  end
  it 'should success exec with no argument' do
    @command.exec([]).should be == 'command return value'
  end
end

describe Command,'with some arguments' do
  before(:each) do
    @context=CommandContext.new
  end
  it 'should execute the command' do
    this=self
    cmd=Command.new('cmd',ArgumentParser.new(TypeParser.new,[ [:arg1,String], [:arg2,Numeric], [:arg3,Date] ])) {
      [@arg1,@arg2,@arg3].should this.be == ['hage',100,Date.new(2008,10,11)]
      'executed'
    }
    cmd.exec(['hage','100','20081011']).should be == 'executed'
  end
end
