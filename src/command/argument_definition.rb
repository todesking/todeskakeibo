class ArgumentDefinition
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
        result[name]=@convertion.parse(args.shift,type)
      else
        raise ArgumentError.new('arguments too short') unless opts.has_key? :default
        result[name]=opts[:default]
      end
    end
    raise ArgumentError.new('arguments too long') if 0 < args.length
    result
  end
  def to_str
    @defs.map{|d|
      arg="#{d[0].to_s}:#{d[1].to_s}"
      arg="[#{arg}]" if (d[2]||{}).has_key? :default
      arg
    }.join(' ')
  end
end
