class DateParser
  def initialize base_date=Date.new
    @base_date=base_date
    @start_of_month=1
  end

  attr_accessor :base_date
  attr_accessor :start_of_month

  def today
    Date.today
  end

  def parse str
    case str.strip
    when /^(\d{4})(\d{2})(\d{2})$/
      Date.new($1.to_i,$2.to_i,$3.to_i)
    when /^(\d{2})(\d{2})$/
      Date.new(@base_date.year,$1.to_i,$2.to_i)
    when /^(\d{1,2})$/
      Date.new(@base_date.year,@base_date.month,$1.to_i)
    when /^today$/
      self.today
    when /^yesterday$/
      self.today-1
    when /^d-(\d+)$/
      self.today - $1.to_i
    else
      raise ArgumentError.new("unknown format date string: #{str}")
    end
  end
  def month_str_to_i(mname)
    mname=mname.dup
    mname[0]=mname[0,1].upcase
    month=Date::ABBR_MONTHNAMES.index mname
    raise ArgumentError.new("unknown month name: #{$1}") if month.nil?
    return month
  end
  def parse_range str
    result=case str.strip
           when /^([A-Za-z]{3})-([A-Za-z]{3})$/
             from=month_str_to_i($1)
             to=month_str_to_i($2)
             if from <= to
               diff=to-from+1
             else
               diff=(to+12)-from+1
             end
             d=Date.new(@base_date.year,from,1)
             d..((d>>diff)-1)
           when /-/ # date-date
             d_start,d_end=str.split('-')
             parse(d_start)..parse(d_end)
           when /^\d{1,2}$/ # mm
             m=str.to_i
             d=Date.new(@base_date.year,m,1)
             create_shifted_range(d,(d>>1)-1)
           when /^\d{4}$/ # yyyy
             y=str.to_i
             Date.new(y,1,1)..Date.new(y,12,31)
           when /^([A-Za-z]{3})$/ # month name
             month=month_str_to_i($1)
             d=Date.new(@base_date.year,month,1)
             create_shifted_range(d,(d>>1)-1)
           when /^(\d+)([mwd])$/ # nd: 今日を含むn日 nm: ここnヶ月
             d=self.today
             case $2
             when 'm'
               ((d<<$1.to_i)+1)..d
             when 'w'
               (d-($1.to_i*7-1))..d
             when 'd'
               (d-($1.to_i-1))..d
             end
           when /^q([1-4])$/ # quarter 1-4
             d=Date.new(@base_date.year,[4,7,10,1][$1.to_i-1],1)
             d..((d>>3)-1)
           else
             raise ArgumentError.new("unknown format date range string: #{str}")
           end
    return result
  end
  def create_shifted_range(a,b)
    (a+@start_of_month-1)..(b+@start_of_month-1)
  end
end
