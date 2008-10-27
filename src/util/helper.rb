module Helper
  def self.create_date_range(year,month=nil,date=nil)
    raise ArgumentError.new('year must not null') if year.nil?
    if month.nil?
      Date.new(year,1,1)..Date.new(year+1,1,1)-1
    elsif date.nil?
      Date.new(year,month,1)..(Date.new(year,month,1) >> 1)-1
    else
      Date.new(year,month,date)..Date.new(year,month,date)
    end
  end
end
