class TypeParser
  def initialize
    @mapping={}
  end
  def parse(str,type)
    if @mapping.has_key? type
      @mapping[type].call str
    else
      case
      when type == String
        str
      when type == Numeric
        str.to_i
      when type == Date && str.strip.length==8
        s=str.strip
        Date.new(s[0..3].to_i,s[4..5].to_i,s[6..7].to_i)
      else
        raise ArgumentError.new("unsupported type: "+type.to_s)
      end
    end
  end
  def define_mapping(type,&block)
    @mapping[type]=block
  end
end
