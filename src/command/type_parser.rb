class TypeParser
  def parse(str,type)
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
