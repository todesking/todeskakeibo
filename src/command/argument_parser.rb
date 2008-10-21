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
      d=defs.shift
      name,type=d
      a=args.shift
      result[name]=parse_argument(a,type)
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
    when type == Date
      case str.strip
      when /^(\d{4})(\d{2})(\d{2})$/
        Date.new($1.to_i,$2.to_i,$3.to_i)
      when /^(\d{2})(\d{2})$/
        Date.new(@context.base_date.year,$1.to_i,$2.to_i)
      when /^(\d{1,2})$/
        Date.new(@context.base_date.year,@context.base_date.month,$1.to_i)
      else
        raise ArgumentError.new("unknown format date string: #{str}")
      end
    else
      raise ArgumentError.new("unsupported type: "+type.to_s)
    end
  end
end
