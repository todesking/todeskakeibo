require File.dirname(__FILE__)+'/'+'../../src/command/command.rb'

describe Command,'with no arguments' do
  before(:each) do
    @command=Command.new('command',[]) do
      'command return value'
    end
  end
  it 'should raise error when arguments passed' do
    pending 'later(after implement argument parser)'
    lambda{@command.exec('some arguments')}.should raise_error(ArgumentError)
  end
  it 'should success exec with no argument' do
    pending 'later(after implement argument parser)'
    @command.exec('').should be == 'command return value'
  end
end
