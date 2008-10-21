require File.dirname(__FILE__)+'/'+'command_context.rb'

class CommandParser
  attr_reader :context
  def initialize
    @context=CommandContext.new
    @commands={}
  end
  def define_command(name,arg_defs=[],&body)
    raise ArgumentError if body.nil?
    @commands[name]=body
  end
  def exec(command_string)
    name=command_string
    @commands[name].call
  end
end
