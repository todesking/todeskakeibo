require File.dirname(__FILE__)+'/'+'command.rb'
require File.dirname(__FILE__)+'/'+'argument_parser.rb'
require File.dirname(__FILE__)+'/'+'type_parser.rb'

class CommandParser
  def initialize(type_parser=TypeParser.new)
    @commands={}
    @type_parser=type_parser
  end
  attr_reader :type_parser
  def define_command(name,arg_defs=[],&body)
    raise ArgumentError.new('block not given') if body.nil?
    raise ArgumentError.new('duplicated name') if @commands.has_key? name

    @commands[name]=Command.new(name,ArgumentParser.new(@type_parser,arg_defs),&body)
  end
  def execute(command_string)
    args=command_string.split(' ')
    name=args.shift
    raise ArgumentError.new('unknown command') unless @commands.has_key? name
    @commands[name].execute args
  end
  def define_alias(name,alias_for)
    raise ArgumentError.new("name #{name} was already exists") if @commands.has_key? name
    raise ArgumentError.new("command #{alias_for} was undefined") if !@commands.has_key? alias_for
    @commands[name]=@commands[alias_for]
  end
end
