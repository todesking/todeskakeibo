class Command
  attr_reader :name
  attr_reader :arg_defs
  def initialize(name,arg_defs,&body)
    raise ArgumentError.new('block must be given') if body.nil?
    @name=name
    @arg_defs=arg_defs
    @body=body
  end
  def execute args
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
    name=args.shift
    @contents[name].execute(args)
  end
end
