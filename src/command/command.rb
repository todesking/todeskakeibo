class Command
  def initialize(name,arg_defs)
    @name=name
    @arg_defs=arg_defs
  end
  def exec args_string
    args=parse_args(args_string)
  end
end
