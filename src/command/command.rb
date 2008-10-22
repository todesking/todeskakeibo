class Command
  attr_reader :name
  def initialize(name,arg_parser,&body)
    raise ArgumentError.new('block must be given') if body.nil?
    @name=name
    @arg_parser=arg_parser
    @body=body
  end
  def execute args
    args=@arg_parser.parse(args)
    execution_context=Object.new
    args.each{|k,v|
      execution_context.instance_variable_set('@'+k.to_s,v)
    }
    execution_context.instance_eval(&@body)
  end
end
