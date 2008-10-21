require File.dirname(__FILE__)+'/'+'../../src/command/command.rb'

describe Command,'with no arguments' do
  before(:each) do
    @context=CommandContext.new
    @command=Command.new(@context,'command',[]) do
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
