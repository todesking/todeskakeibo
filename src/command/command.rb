class Command
  attr_reader :name
  attr_reader :arg_defs
  attr_reader :sub_commands
  def initialize(name,arg_defs,&body)
    raise ArgumentError.new('block must be given') if body.nil?
    @name=name
    @arg_defs=arg_defs
    @body=body
    @sub_commands={}
  end

  def execute args
    return sub_command(args.first).execute(args[1..-1]) if !args.empty? && !sub_command(args.first).nil?
    args=@arg_defs.parse(args)
    execution_context=Object.new
    args.each{|k,v|
      execution_context.instance_variable_set('@'+k.to_s,v)
    }
    execution_context.instance_eval(&@body)
  end

  def to_str
    [name,arg_defs.to_str].join(' ').strip
  end

  # define_sub_command(Command) or define_sub_command(name,type_parser,argdefs,&body)
  def define_sub_command *args,&block
    case args.length
    when 1
      command=args[0]
      raise ArgumentError.new("sub command #{command.name} is already exists") unless sub_command(command.name).nil?
      @sub_commands[command.name]=command
    when 3
      name=args[0]
      type_parser=args[1]
      argdefs=args[2]
      raise ArgumentError.new("sub command #{name} is already exists") unless sub_command(name).nil?
      @sub_commands[name]=Command.new(name,ArgumentDefinition.new(type_parser,argdefs),&block)
    else
      raise ArgumentError.new('illegal argument length')
    end
  end

  def alias_sub_command name,alias_for
    raise ArgumentError.new("alias name #{name} is already used") unless sub_command(name).nil?
    raise ArgumentError.new("target name #{name} is undefined") unless !sub_command(alias_for).nil?
    @sub_commands[name]=@sub_commands[alias_for]
  end

  def sub_command name
    @sub_commands[name]
  end

  #todo: obsolete
  def sub_container(*args)
    raise ArgumentError.new("#{name}: theres no sub command: #{args.join(' ')}") unless args.empty?
    self
  end
end
