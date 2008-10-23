require File.dirname(__FILE__)+'/'+'command.rb'
require File.dirname(__FILE__)+'/'+'argument_definition.rb'
require File.dirname(__FILE__)+'/'+'type_parser.rb'

class CommandParser
  def initialize(type_parser=TypeParser.new)
    @commands={}
    @type_parser=type_parser
  end
  attr_reader :type_parser
  def define_command(name,arg_defs=[],&body)
    if name.instance_of? Array
      raise ArgumentError.new('name is empty') if name.empty?
      define_command(name[0],arg_defs,&body)
      define_alias(name[1..-1],name[0])
      return
    end
    raise ArgumentError.new('block not given') if body.nil?
    raise ArgumentError.new('duplicated name') if @commands.has_key? name

    @commands[name]=Command.new(name,ArgumentDefinition.new(@type_parser,arg_defs),&body)
  end
  def define_hierarchical_command(names,arg_defs=[],&body)
    raise ArgumentError.new('names.length < 2') unless 1 < names.length
    top_name=names.first
    top_name=[top_name] unless top_name.instance_of? Array
    package=@commands[top_name.first]||CommandContainer.new(top_name.first)
    top_name.each{|tn| @commands[tn]=package}
    package=package.define_sub_container(*names[1..-2])
    package.define_command(names.last,Command.new(names.last,ArgumentDefinition.new(@type_parser,arg_defs),&body))
  end
  def execute(command_string)
    args=command_string.split(' ')
    name=args.shift
    raise ArgumentError.new("unknown command: #{name}") unless @commands.has_key? name
    @commands[name].execute args
  end
  def define_alias(name,alias_for)
    return name.each{|n| define_alias(n,alias_for)} if name.instance_of? Array

    raise ArgumentError.new("command #{name} was already exists") if @commands.has_key? name
    raise ArgumentError.new("command #{alias_for} was undefined") if !@commands.has_key? alias_for

    @commands[name]=@commands[alias_for]
  end
  def command(name)
    return @commands[name]
  end
  def commands
    return @commands.clone
  end
  def non_alias_commands
    return @commands.reject{|k,v| v.name != k}
  end
  def aliases_for command
    return @commands.reject{|k,v| v!=command || k==v.name}
  end
end
