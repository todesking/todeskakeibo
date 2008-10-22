require File.dirname(__FILE__)+'/'+'command/command_parser.rb'
require File.dirname(__FILE__)+'/'+'model/transaction.rb'
require File.dirname(__FILE__)+'/'+'model/endpoint_alias.rb'
require File.dirname(__FILE__)+'/'+'util/relative_date_parser.rb'


class Controller
  def initialize
    @parser=CommandParser.new
    @date_parser=RelativeDateParser.new
    parser=@parser
    date_parser=@date_parser

    # define argument types
    @parser.type_parser.define_mapping(Endpoint) {|ep_name|
      EndpointAlias.lookup(ep_name)
    }

    @parser.type_parser.define_mapping(Date) {|date|
      @date_parser.parse(date)
    }

    # define commands
    define_command('transaction',[[:date,Date], [:src,Endpoint], [:dest,Endpoint], [:amount,Numeric]]) do
      Transaction.new(:date=>@date, :src=>@src, :dest=>@dest, :amount=>@amount).save
    end
    define_alias(['t'],'transaction')

    define_command('account',[[:date,Date], [:endpoint,Endpoint], [:amount,Numeric]]) do
      AccountHistory.new(:date=>@date, :endpoint=>@endpoint, :amount=>@amount).save
    end
    define_alias(['a'],'account')

    define_command('base_date',[[:date,Date]]) do
      date_parser.base_date=@date
    end
    define_alias('bd','base_date')

    define_command('endpoint',[[:ep_name,String],[:parent,Endpoint,{:default=>nil}]]) do
      Endpoint.new(:name=>@ep_name,:parent=>@parent).save
    end
    define_alias('ep','endpoint')
    
    define_command('endpoint_alias',[[:alias_name,String],[:alias_for,Endpoint]]) do
      EndpointAlias.new(:name=>@alias_name,:endpoint=>@alias_for).save
    end
    define_alias('epa','endpoint_alias')

    # define commands(untestable, most of is 'show' command)
    define_command('help',[[:sub_command,String,{:default=>nil}]]) do
      default_str= <<EOS
help : show this message
help commands : show commands with aliases
EOS
      case @sub_command
      when 'commands'
        lines=[]
        parser.non_alias_commands.each{|k,v|
          lines << "#{v.to_str}"
          lines << "  aliases: #{parser.aliases_for(v).map{|k,v|k}.join(' ')}" unless parser.aliases_for(v).empty?
        }
        lines.join("\n")
      when nil
        default_str
      else
        default_str
      end
    end
    define_alias(['h','?','he'],'help')

    define_command('endpoints',[]) do
      def epp(res,level,ep)
        res << '  '*level + ep.name
        ep.children.each{|c| epp(res,level+1,c)}
      end
      lines=['Endpoints:']
      ep_root=Endpoint.find(:all,:conditions=>{:parent=>nil})
      ep_root.each{|e|
        epp(lines,1,e)
      }
      lines.join("\n")
    end
    define_alias('eps','endpoints')
  end
  def define_command(name,defs,&block)
    @parser.define_command(name,defs,&block)
  end
  def define_alias(aliases,command)
    @parser.define_alias(aliases,command)
  end
  def execute command
    case command
    when String
      return nil if command.strip.empty?
      @parser.execute command.strip
    when Array
      command.each{|l|
        next if l.strip.empty?
        @parser.execute l.strip
      }
    end
  end
end
