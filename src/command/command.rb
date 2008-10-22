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
end
