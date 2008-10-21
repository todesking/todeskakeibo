require File.dirname(__FILE__)+'/'+'command/command_parser.rb'

require File.dirname(__FILE__)+'/'+'model/transaction.rb'


class Controller
  def initialize
    @parser=CommandParser.new

    # define argument types
    @parser.type_parser.define_mapping(Endpoint) {|ep_name|
      EndpointAlias.lookup(ep_name)
    }

    # define commands
    @parser.define_command('transaction',[[:date,Date], [:src,Endpoint], [:dest,Endpoint], [:amount,Numeric]]) do
      Transaction.new(:date=>@date, :src=>@src, :dest=>@dest, :amount=>@amount).save
    end
  end
  def execute command
    @parser.execute command
  end
end
