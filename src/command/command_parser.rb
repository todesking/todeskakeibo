require File.dirname(__FILE__)+'/'+'command_context.rb'

class CommandParser
  attr_reader :context
  def initialize
    @context=CommandContext.new
    @commands={}
  end
  def define_command(name,arg_defs=[],&body)
    raise ArgumentError if body.nil?
    @commands[name]=Command.new(name,ArgumentParser.new(TypeParser.new,arg_defs),&body)
  end
  def exec(command_string)
    args=command_string.split(' ')
    name=args.shift
    raise ArgumentError.new('unknown command') unless @commands.has_key? name
    @commands[name].exec args
  end
end
