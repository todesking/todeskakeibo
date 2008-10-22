class ArgumentParser
  def initialize(convertion,defs)
    var_names={}
    default_appeared=false
    defs.each{|d|
      var_names[d[0]]=true
      has_default=(d[2]||{}).has_key? :default
      raise ArgumentError.new('trailing non-default argument') if default_appeared && !has_default
      default_appeared=true if has_default
    }
    raise ArgumentError.new('duplicated variable name') if defs.length != var_names.length
    @convertion=convertion
    @defs=defs
  end
  def parse(args)
    args=args.clone
    defs=@defs.clone
    result={}
    while(0 < defs.length)
      d=defs.shift
      name,type,opts=d
      opts||={}
      if 0 < args.length
        a=args.shift
      else
        raise ArgumentError.new('arguments too short') unless opts.has_key? :default
        a=opts[:default]
      end
      result[name]=@convertion.parse(a,type)
    end
    raise ArgumentError.new('arguments too long') if 0 < args.length
    result
  end
end
