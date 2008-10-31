class DateParser
  def initialize base_date=Date.new
    @base_date=base_date
  end

  attr_accessor :base_date
  def parse str
    case str.strip
    when /^(\d{4})(\d{2})(\d{2})$/
      Date.new($1.to_i,$2.to_i,$3.to_i)
    when /^(\d{2})(\d{2})$/
      Date.new(@base_date.year,$1.to_i,$2.to_i)
    when /^(\d{1,2})$/
      Date.new(@base_date.year,@base_date.month,$1.to_i)
    when /^today$/
      Date.today
    when /^yesterday$/
      Date.today-1
    when /^d-(\d+)$/
      Date.today - $1.to_i
    else
      raise ArgumentError.new("unknown format date string: #{str}")
    end
  end
  def parse_range str
    case str.strip
    when /-/
      d_start,d_end=str.split('-')
      parse(d_start)..parse(d_end)
    when /^\d{2}$/ #month
      m=str.to_i
      d=Date.new(@base_date.year,m,1)
      d..((d>>1)-1)
    when /^\d{4}$/
      y=str.to_i
      Date.new(y,1,1)..Date.new(y,12,31)
    when /^[A-Za-z]+$/
      mname=str.downcase
      mname[0]=mname[0,1].upcase
      month=Date::ABBR_MONTHNAMES.index mname
      raise ArgumentError.new("unknown month name: #{mname}") if month.nil?
      d=Date.new(@base_date.year,month,1)
      d..((d>>1)-1)
    else
      raise ArgumentError.new("unknown format date range string: #{str}")
    end
  end
end
