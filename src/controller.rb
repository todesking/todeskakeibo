require File.dirname(__FILE__)+'/'+'command/command_parser.rb'
require File.dirname(__FILE__)+'/'+'model/transaction.rb'
require File.dirname(__FILE__)+'/'+'model/endpoint_alias.rb'
require File.dirname(__FILE__)+'/'+'util/relative_date_parser.rb'
require File.dirname(__FILE__)+'/'+'util/data_structure_formatter.rb'


class Controller
  def type_parser
    @parser.type_parser
  end
  def initialize
    @parser=CommandParser.new
    @date_parser=RelativeDateParser.new
    parser=@parser
    date_parser=@date_parser
    date_parser.base_date=Date.today

    # define argument types
    @parser.type_parser.define_mapping(Endpoint) {|ep_name|
      ep=EndpointAlias.lookup(ep_name)
      raise ArgumentError.new("unknown endpoint name: #{ep_name}") if ep.nil?
      ep
    }

    @parser.type_parser.define_mapping(Date) {|date|
      @date_parser.parse(date)
    }

    # define commands
    @parser.define_hierarchical_command([ ['delete','del'],['transaction','tr'] ],[ [:id,Numeric] ]) do
      Transaction.find_by_id(@id).destroy
    end

    define_command(['transaction','t'],[[:date,Date], [:src,Endpoint], [:dest,Endpoint], [:amount,Numeric]]) do
      Transaction.new(:date=>@date, :src=>@src, :dest=>@dest, :amount=>@amount).save
    end

    define_command(['account','a'],[[:date,Date], [:endpoint,Endpoint], [:amount,Numeric]]) do
      AccountHistory.new(:date=>@date, :endpoint=>@endpoint, :amount=>@amount).save
    end

    define_command(['base_date','bd'],[[:date,Date,{:default=>nil}]]) do
      if @date.nil?
        "base date: #{date_parser.base_date.to_s}"
      else
        date_parser.base_date=@date
      end
    end

    define_command(['endpoint','ep'],[[:ep_name,String],[:parent,Endpoint,{:default=>nil}]]) do
      Endpoint.new(:name=>@ep_name,:parent=>@parent).save
    end
    
    define_command(['endpoint_alias','epa'],[[:alias_name,String],[:alias_for,Endpoint]]) do
      EndpointAlias.new(:name=>@alias_name,:endpoint=>@alias_for).save
    end

    # define commands(untestable, most of is 'show' command)
    define_command(['help','h','?','he'],[[:sub_command,String,{:default=>nil}]]) do
      default_str= <<EOS
help : show this message
help commands : show commands with aliases
help <command-name> : show command usage
EOS
      case @sub_command
      when 'commands'
        lines=[]
        parser.non_alias_commands.each{|k,v|
          lines << "#{v.to_str}"
          lines << "aliases: #{parser.aliases_for(v).map{|k,v|k}.join(' ')}" unless parser.aliases_for(v).empty?
        }
        lines.join("\n")
      when nil
        default_str
      else
        cmd=parser.command(@sub_command)
        if cmd.nil?
          "undefined command: #{@sub_command}"
        else
          lines=[]
          lines << "#{cmd.to_str}"
          lines << "aliases: #{parser.aliases_for(cmd).map{|k,v|k}.join(' ')}" unless parser.aliases_for(cmd).empty?
          lines.join("\n")
        end
      end
    end

    define_command(['endpoints','eps'],[]) do
      ac=DataStructureFormatter::Tree::Accessor.new
      ac.child_enumerator {|target| target.children}
      ac.value_accessor {|target| target.name}
      fmt=DataStructureFormatter::Tree::Formatter.new ac
      msg=''
      Endpoint.find(:all,:conditions=>{:parent=>nil}).each{|ep|
        msg << fmt.format(ep)
      }
      msg
    end

    define_command(['transactions','trs']) do
      ac=DataStructureFormatter::Table::Accessor.new
      ac.row_enumerator {|data| data}
      ac.column_enumerator {|row|
        [row.id,row.date.to_s,row.src.name,row.dest.name,row.amount,row.description]
      }
      fmt=DataStructureFormatter::Table::Formatter.new ac,['id','date','src','dest','amount','descr.']
      fmt.format(Transaction.find(:all))
    end
  end
  def define_command(name,defs=[],&block)
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
