class Controller
  def initialize
    @parser=CommandParser.new
  end
  def execute command
    @parser.execute command
  end
end
