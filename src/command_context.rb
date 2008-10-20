class CommandContext
  def date(str)
    case str
    when /(\d{4})(\d{2})(\d{2})/
      Date.new($1.to_i,$2.to_i,$3.to_i)
    else
      raise ArgumentError.new("unknown format date string: #{str}")
    end
  end
  attr_accessor :base_date
end
