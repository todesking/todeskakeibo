require File.dirname(__FILE__)+'/'+'command_context.rb'

class CommandParser
  attr_reader :context
  def initialize
    @context=CommandContext.new
  end
end
