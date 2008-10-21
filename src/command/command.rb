class Command
  def initialize(context,name,arg_defs,&body)
    raise ArgumentError('block must be given') if body.nil?
    @name=name
    @arg_parser=ArgumentParser.new(context,arg_defs)
    @body=body
  end
  def exec args
    args=@arg_parser.parse(args)
    execution_context=Object.new
    args.each{|k,v|
      execution_context.instance_variable_set('@'+k.to_s,v)
    }
    execution_context.instance_eval(&@body)
  end
end
