require File.dirname(__FILE__)+'/'+'../../src/command/command.rb'

describe Command,'when initialize' do
  it 'should error when no block given' do
    Command.new('hoge',ArgumentDefinition.new(TypeParser.new,[])){} #success
    lambda{Command.new('hoge',ArgumentDefinition.new([]))}.should raise_error(ArgumentError)
  end
end

describe Command do
  it 'should have #sub_container method' do
    c=Command.new('cmd',ArgumentDefinition.new(TypeParser.new,[])){}
    c.sub_container.should be c
    lambda{c.sub_container('hage')}.should raise_error(ArgumentError)
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

describe Command,'about sub command' do
  before(:each) do
    @c=Command.new('command',ArgumentDefinition.new(TypeParser.new,[])){'command'}
    @carg=Command.new('command_with_arg',ArgumentDefinition.new(TypeParser.new,[[:arg,String]])){'command_with_arg'}
    @csub=Command.new('sub',ArgumentDefinition.new(TypeParser.new,[])){'sub'}
  end

  it '#define_sub_command accepts user-frientry command creation arguments' do
    @c.define_sub_command('sub_command',TypeParser.new,[ [:arg,String] ]) do
      'sub_command'
    end
    @c.execute(['sub_command','hoge']).should == 'sub_command'
  end

  it 'should define sub command by #define_sub_command and reference by #sub_command' do
    @c.define_sub_command(@csub)
    @c.sub_command('sub').should be @csub
  end
  
  it '#define_sub_command should error when argument length==3 and block not given' do
    lambda{@c.define_sub_command('name',TypeParser.new,[])}.should raise_error(ArgumentError)
    @c.define_sub_command('name',TypeParser.new,[]){} # its success
  end

  it '#define_sub_command should error when illegal argument number' do
    lambda{@c.define_sub_command('name',TypeParser.new,[],'fuba'){}}.should raise_error(ArgumentError)
  end

  it '#define_sub_command should error when command already exists' do
    @c.define_sub_command(@csub)
    lambda{@c.define_sub_command(@csub)}.should raise_error(ArgumentError)
    @c.define_sub_command('sub_',TypeParser.new,[]){} # this not an error
    lambda{@c.define_sub_command('sub',TypeParser.new,[]){}}.should raise_error(ArgumentError)
  end

  it '#execute should invoke proper Command object(self or sub command)' do
    @carg.execute(['foo']).should == 'command_with_arg'
    @carg.execute(['sub']).should == 'command_with_arg'
    @carg.define_sub_command(@csub)
    @carg.sub_command('sub').should be @csub
    @carg.execute(['sub']).should == 'sub'
    @carg.execute(['foo']).should == 'command_with_arg'
  end

  it '#sub_commands should list up all of sub command' do
    @c.sub_commands.should be_empty
    @c.define_sub_command(@csub)
    @c.sub_commands.should_not be_empty
  end

  it '#alias_sub_command should make alias of the sub commnd' do
    @c.define_sub_command(@csub)
    @c.sub_command('sub').should be @csub
    @c.sub_command('sub_alias').should be_nil
    @c.alias_sub_command('sub_alias','sub')
    @c.sub_command('sub_alias').should be @csub
  end

  it '#alias_sub_command should error when exists name or undefined alias_for passed' do
    @c.define_sub_command @csub
    lambda{@c.alias_sub_command 'sub','sub'}.should raise_error(ArgumentError)
    lambda{@c.alias_sub_command 'hoge','hage'}.should raise_error(ArgumentError)
    @c.alias_sub_command 'fuga','sub'
    @c.sub_command('fuga').should be @csub
  end
end
