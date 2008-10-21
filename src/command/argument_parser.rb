class ArgumentParser
  def initialize(context,defs)
    @context=context
    @defs=defs
  end
  def parse(args)
    args=args.clone
    defs=@defs.clone
    result={}
    while(0 < defs.length)
      d=@defs.shift
      name,type=d
      a=args.shift
      result[name]=a
    end
    raise ArgumentError.new('arguments too long') if 0 < args.length
    result
  end
  def parse_argument(str,type)
    case
    when type == String
      str
    when type == Numeric
      str.to_i
    else
      raise ArgumentError.new("unsupported type: "+type.to_s)
    end
  end
end
