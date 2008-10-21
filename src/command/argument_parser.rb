class ArgumentParser
  def initialize(convertion,defs)
    var_names={}
    defs.each{|d|var_names[d[0]]=true}
    raise ArgumentError.new('duplicated variable name') if defs.length != var_names.length
    @convertion=convertion
    @defs=defs
  end
  def parse(args)
    args=args.clone
    defs=@defs.clone
    result={}
    while(0 < defs.length)
      raise ArgumentError.new('arguments too short') if args.length==0
      d=defs.shift
      name,type=d
      a=args.shift
      result[name]=@convertion.parse(a,type)
    end
    raise ArgumentError.new('arguments too long') if 0 < args.length
    result
  end
end
