require File.dirname(__FILE__)+'/'+'../../src/command/command_parser.rb'

describe CommandParser do
  before(:each) do
    @cp=CommandParser.new
    @cp.define_command('command1',[]){}
    @cp.define_command('command2',[]){}
    @cp.define_command('command3',[]){}
    @cp.define_alias('c1','command1')
    @cp.define_alias('c3','command3')
  end
  it 'should know all commands' do
    @cp.commands.should be == {
      'command1' => @cp.command('command1'),
      'command2' => @cp.command('command2'),
      'command3' => @cp.command('command3'),
      'c1' => @cp.command('command1'),
      'c3' => @cp.command('command3')
    }
  end
  it 'should know non-alias commands' do
    @cp.non_alias_commands.should be == {
      'command1' => @cp.command('command1'),
      'command2' => @cp.command('command2'),
      'command3' => @cp.command('command3')
    }
  end
  it 'should know command\'s aliases' do
    @cp.aliases_for(@cp.command('command1')).should be == {
      'c1' => @cp.command('command1')
    }
  end
end

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

describe CommandParser,'#define_command' do
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

  it 'should define command with aliases at once' do
    @parser.define_command(['hage','ha','h'],[]){'hage'}
    @parser.command('hage').should_not be_nil
    @parser.execute('hage').should == 'hage'
    @parser.execute('ha').should == 'hage'
    @parser.execute('h').should == 'hage'
  end

  it 'should error when empty array is passed as name' do
    lambda{@parser.define_command([],[]){}}.should raise_error(ArgumentError)
  end
end

describe CommandParser,'with hierarchical command' do
  before(:each) do
    @parser=CommandParser.new
  end

  it '#define_hierarchical_command should error when names.length < 2' do
    pending
    lambda{@parser.define_hierarchical_command(['hoge'],[]){}}.should raise_error(ArgumentError)
    lambda{@parser.define_hierarchical_command([],[]){}}.should raise_error(ArgumentError)
    @parser.define_hierarchical_command(['hoge','hage'],[]){}.name.should  == 'hage'
  end

  it 'should define/reference/execute hierarchical command' do
    pending
    @parser.define_hierarchical_command(['svn','update'],[[:target,String]]) do
      @target
    end
    @parser.define_hierarchical_command(['svn','status'],[]) do
      'svn status'
    end
    @parser.command('svn').should_not be_nil
    @parser.command('svn').sub_container('status').name.should == 'status'
    @parser.execute('svn status').should == 'svn status'
    @parser.execute('svn update hage').should == 'hage'
  end

  it 'should define hierarchical command with aliases' do
    pending
    @parser.command('del').should be_nil
    @parser.command('delete').should be_nil
    @parser.define_hierarchical_command([ ['delete','del'],['transaction','tr'] ], []) do
      'delete_transaction'
    end
    @parser.command('del').should_not be_nil
    @parser.command('delete').sub_container('tr').should_not be_nil
  end
end

describe CommandParser,'#execute' do
  before(:each) do
    @parser=CommandParser.new
  end

  it 'should error when undefined command executed' do
    lambda{@parser.execute('hage')}.should raise_error(ArgumentError)
  end

  it 'should error when command executed with wrong number of arguments' do
    @parser.define_command('command',[[:string_arg,String]]) {}
    lambda{@parser.execute('command')}.should raise_error(ArgumentError)
    lambda{@parser.execute('command hoge hage')}.should raise_error(ArgumentError)
  end

  it 'should execute command with no args' do
    @parser.define_command('the_command') do
      100
    end
    @parser.execute('the_command').should be == 100
  end

  it 'should execute command with one string argument' do
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

  it 'should define multiple alias names at once' do
    @parser.define_command('transaction',[]) {}
    @parser.define_alias(['t','tr'],'transaction')
    @parser.command('t').should be == @parser.command('transaction')
    @parser.command('tr').should be == @parser.command('transaction')
  end
end
