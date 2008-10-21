class CommandContext
  attr_accessor :base_date
  def date str
    case str.strip
    when /^(\d{4})(\d{2})(\d{2})$/
      Date.new($1.to_i,$2.to_i,$3.to_i)
    when /^(\d{2})(\d{2})$/
      Date.new(@base_date.year,$1.to_i,$2.to_i)
    when /^(\d{1,2})$/
      Date.new(@base_date.year,@base_date.month,$1.to_i)
    else
      raise ArgumentError.new("unknown format date string: #{str}")
    end
  end
end
