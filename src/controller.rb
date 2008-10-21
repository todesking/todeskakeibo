require File.dirname(__FILE__)+'/'+'command/command_parser.rb'
require File.dirname(__FILE__)+'/'+'model/transaction.rb'
require File.dirname(__FILE__)+'/'+'util/relative_date_parser.rb'


class Controller
  def initialize
    @parser=CommandParser.new
    @date_parser=RelativeDateParser.new

    # define argument types
    @parser.type_parser.define_mapping(Endpoint) {|ep_name|
      EndpointAlias.lookup(ep_name)
    }

    @parser.type_parser.define_mapping(Date) {|date|
      @date_parser.parse(date)
    }

    # define commands
    @parser.define_command('transaction',[[:date,Date], [:src,Endpoint], [:dest,Endpoint], [:amount,Numeric]]) do
      Transaction.new(:date=>@date, :src=>@src, :dest=>@dest, :amount=>@amount).save
    end
    @parser.define_command('account',[[:date,Date], [:endpoint,Endpoint], [:amount,Numeric]]) do
      AccountHistory.new(:date=>@date, :endpoint=>@endpoint, :amount=>@amount).save
    end
    date_parser=@date_parser
    @parser.define_command('base_date',[[:date,Date]]) do
      date_parser.base_date=@date
    end
  end
  def execute command
    @parser.execute command
  end
end
