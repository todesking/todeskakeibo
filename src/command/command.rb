class Command
  attr_reader :name
  attr_reader :arg_defs
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
  def define_sub_command name,command
    raise ArgumentError.new("sub command #{name} is already exists") unless sub_command(name).nil?
    @sub_commands[name]=command
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

class CommandContainer
  attr_reader :name
  def initialize name
    @name=name
    @contents={}
  end
  def define_command name,command
    name=[name] unless name.instance_of? Array
    name.each{|n| @contents[n]=command}
    command
  end
  def define_sub_container *names
    return self if names.empty?
    name=names.shift
    name=[name] unless name.instance_of? Array
    sub_cmd=@contents[name.first] || CommandContainer.new(name.first)
    name.each{|n| @contents[n]=sub_cmd }
    sub_cmd.define_sub_container(*names)
  end
  def sub_container *names
    return self if names.empty?
    name=names.shift
    sub=@contents[name]
    return nil if sub.nil?
    return sub.sub_container(*names)
  end
  def execute args
    raise ArgumentError.new("#{self.name}: subcommand not given") if args.empty?
    name=args.shift
    cmd=@contents[name]
    raise ArgumentError.new("#{self.name}: unknown subcommand: #{name}") if cmd.nil?
    cmd.execute(args)
  end
  def to_str
    "#{name} [#{@contents.values.uniq.map{|v|v.to_str}.join('|')}]"
  end
end
