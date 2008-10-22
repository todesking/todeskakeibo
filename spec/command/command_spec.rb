require File.dirname(__FILE__)+'/'+'../../src/command/command.rb'

describe Command,'when initialize' do
  it 'should error when no block given' do
    lambda{Command.new('hoge',ArgumentDefinition.new([]))}.should raise_error(ArgumentError)
  end
end

describe Command,'with no arguments' do
  before(:each) do
    @command=Command.new('command',ArgumentDefinition.new(TypeParser.new,[])) do
      'command return value'
    end
  end
  it 'should raise error when arguments passed' do
    lambda{@command.execute('some arguments')}.should raise_error(ArgumentError)
  end
  it 'should success execute with no argument' do
    @command.execute([]).should be == 'command return value'
  end
  it 'should have human readable string' do
    @command.to_str.should be == 'command'
  end
end

describe Command,'with some arguments' do
  before(:each) do
  end
  it 'should execute the command' do
    this=self
    cmd=Command.new('cmd',ArgumentDefinition.new(TypeParser.new,[ [:arg1,String], [:arg2,Numeric], [:arg3,Date] ])) {
      [@arg1,@arg2,@arg3].should this.be == ['hage',100,Date.new(2008,10,11)]
      'executed'
    }
    cmd.execute(['hage','100','20081011']).should be == 'executed'
  end
  it 'should have name' do
    cmd=Command.new('cmd',ArgumentDefinition.new(TypeParser.new,[])){}
    cmd.name.should be == 'cmd'
  end
  it 'should have argument definitions' do
    cmd=Command.new('cmd',ArgumentDefinition.new(TypeParser.new,[])){}
    cmd.arg_defs.should_not be_nil
  end
  it 'should have human readable string' do
    cmd=Command.new('cmd',ArgumentDefinition.new(TypeParser.new,[ [:arg1,String], [:arg2,Numeric], [:arg3,Date] ])) {}
    cmd.to_str.should be == 'cmd arg1:String arg2:Numeric arg3:Date'
  end
end
