require File.dirname(__FILE__)+'/'+'../../src/command/command_context.rb'

describe CommandContext do
  before(:each) do
    @context=CommandContext.new
  end
  it 'should can set base date' do
    @context.base_date=Date.new #only check no-error
  end
end
