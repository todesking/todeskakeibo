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
    @c=Command.new('command',ArgumentDefinition.new(TypeParser.new,[])){}
    @carg=Command.new('command_with_arg',ArgumentDefinition.new(TypeParser.new,[[:arg,String]])){}
    @csub=Command.new('sub-command',ArgumentDefinition.new(TypeParser.new,[ [:arg,String] ])){}
  end

  it 'should define sub command by #define_sub_command and reference by #sub_command' do
    @c.define_sub_command('sub',@csub)
    @c.sub_command('sub').should be @csub
  end
end

describe CommandContainer do
  it 'should have name' do
    CommandContainer.new('name').name.should == 'name'
  end

  it 'should define and reference sub container' do
    cc=CommandContainer.new('hoge')
    cc.sub_container('hage').should be_nil
    cc.define_sub_container('hage').name.should == 'hage'
    cc.sub_container('hage').name.should == 'hage'
  end

  it '#define_sub_container returns self if empty array passed' do
    cc=CommandContainer.new('hoge')
    cc.sub_container().should be == cc
  end

  it '#define_sub_container should return exists instance when name is already defined' do
    cc=CommandContainer.new('hoge')
    cc.define_sub_container('moge')
    cc.sub_container('moge').should be cc.define_sub_container('moge')
  end

  it '#define_sub_container should define sub container with alias names' do
    cc=CommandContainer.new('hoge')
    cc.define_sub_container(['hoge','ho','h'])
    cc.sub_container('hoge').name.should == 'hoge'
    cc.sub_container('ho').name.should == 'hoge'
  end

  it '#command should returns hierarchical sub container/command' do
    cc=CommandContainer.new('java')
    sc_3=cc.define_sub_container('1','2','3')
    cc.sub_container('1','2','3').should be sc_3
  end

  it '#define_command should define new command of the container' do
    c=CommandContainer.new('svn')
    c.define_sub_container('up').define_command('cmd',Command.new('cmd',ArgumentDefinition.new(TypeParser.new,[])){'command'})
    c.execute(['up','cmd']).should == 'command'
    c.sub_container('up','cmd').name.should == 'cmd'
    c.sub_container('up').sub_container('cmd').name.should == 'cmd'
  end

  it '#define_command should return the Command object' do
    c=CommandContainer.new('svn')
    cmd=Command.new('up',ArgumentDefinition.new(TypeParser.new,[])){}
    c.define_command('up',cmd).should be cmd
  end

  it '#execute should error when unknown command' do
    lambda{CommandContainer.new('hage').execute(['hoge','fuga'])}.should raise_error(ArgumentError)
  end

  it '#execute should error when subcommand is empty' do
    cc=CommandContainer.new('hoge')
    cc.define_sub_container('hage')
    lambda{cc.execute([])}.should raise_error(ArgumentError)
  end

  it '#define_sub_container should return deepest container' do
    cc=CommandContainer.new('hoge')
    c3=cc.define_sub_container('1','2','3')
    cc.sub_container('1').sub_container('2').sub_container('3').should be c3
  end

  it 'should store sub command' do
    cc=CommandContainer.new('svn')
    cc.sub_container('up').should be_nil
    cc.define_sub_container('up')
    cc.sub_container('up').should_not be_nil
    cmd1=Command.new('cmd1',ArgumentDefinition.new(TypeParser.new,[])){'sub-command'}
    cc.sub_container('up').define_command('cmd1',cmd1)
    cmd2=Command.new('cmd2',ArgumentDefinition.new(TypeParser.new,[ [:arg,String] ])){'sub-command2 with '+@arg}
    cc.sub_container('up').define_command('cmd2',cmd2)
    cc.execute(['up','cmd1']).should == 'sub-command'
    cc.execute(['up','cmd2','hoge']).should == 'sub-command2 with hoge'
  end

  it 'should have #to_str' do
    cc=CommandContainer.new('hoge')
    cc.define_sub_container('fuga')
    cc.to_str.should_not be_nil
  end
end
