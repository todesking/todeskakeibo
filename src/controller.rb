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
    define_command(['base_date','bd'],[[:date,Date,{:default=>nil}]]) do
      if @date.nil?
        "base date: #{date_parser.base_date.to_s}"
      else
        date_parser.base_date=@date
      end
    end

    @parser.define_command(['delete','del','rm'],[ [:type,String], [:id,Numeric]]) {
      case @type
      when 'transaction','tr'
        table=Transaction
      when 'account_history','ah'
        table=AccountHistory
      when 'endpoint','ep'
        table=Endpoint
      when 'endpoint_alias','epa'
        table=EndpointAlias
      else
        next 'usage: delete [transaction|account_history|endpoint|endpoint_alias]'
      end
      target=table.find_by_id(@id)
      raise "id #{@id} not found" if target.nil?
      target.destroy
      "#{table.name} \##{target.id} was destroied"
    }

    define_command(['transaction','tr','t'],[[:date,Date], [:src,Endpoint], [:dest,Endpoint], [:amount,Numeric], [:description,String,{:default=>nil}]]) do
      tr=Transaction.new(:date=>@date, :src=>@src, :dest=>@dest, :amount=>@amount,:description=>@description)
      tr.save
      "transaction \##{tr.id} added."
    end

    define_command(['account','ac','a'],[[:date,Date], [:endpoint,Endpoint], [:amount,Numeric],[:description,String,{:default=>nil}]]) do
      ah=AccountHistory.new(:date=>@date, :endpoint=>@endpoint, :amount=>@amount, :description=>@description)
      ah.save
      "account history \##{ah.id} added"
    end

    define_command(['endpoint','ep'],[[:ep_name,String],[:parent,Endpoint,{:default=>nil}],[:description,String,{:default=>nil}]]) do
      ep=Endpoint.new(:name=>@ep_name,:parent=>@parent,:description=>@description)
      ep.save
      "enpoint \##{ep.id}(#{ep.name}) added."
    end

    @parser.define_hierarchical_command(['set',['endpoint','ep']],[ [:target,Endpoint], [:property,String],[:value,String] ]) do
      case @property
      when 'parent='
        @parent=EndpointAlias.lookup(@value)
        @target.parent=@parent
        @target.save
      when 'name='
        @target.name=@value
        @target.save
      else
        raise 'set endpoint: unknown property'
      end
      "set endpoint #{@target.name} #{@property} #{@value}"
    end
    
    define_command(['endpoint_alias','epa'],[[:alias_name,String],[:alias_for,Endpoint]]) do
      epa=EndpointAlias.new(:name=>@alias_name,:endpoint=>@alias_for)
      epa.save
      "endpoint alias \##{epa.id}(#{epa.name} => #{@alias_for.name}) added."
    end

    # define commands(untestable, most of is 'show' command)
    define_command(['help','h','he','?'],[ [:arg,String,{:default=>nil}] ]) do
      unless @arg.nil?
        cmd=parser.command(@arg)
        if cmd.nil?
          "help: command #{@arg} is undefined"
        else
          lines=[]
          lines << "#{cmd.to_str}"
          lines << "aliases: #{parser.aliases_for(cmd).map{|k,v|k}.join(' ')}" unless parser.aliases_for(cmd).empty?
          lines.join("\n")
        end
      else
        <<EOS
help : show this message
help commands|co : show commands with aliases
help <command-name> : show command usage
EOS
      end
    end
    @parser.define_hierarchical_command(['help',['commands','co']],[]) do
      lines=[]
      lines << 'Commands:'
      parser.non_alias_commands.each{|k,v|
        lines << "  #{v.to_str}"
        lines << "    aliases: #{parser.aliases_for(v).map{|k,v|k}.join(' ')}" unless parser.aliases_for(v).empty?
      }
      lines.join("\n")
    end

    define_command(['endpoints','eps'],[ [:format_type,String,{:default=>'tree'}] ]) do
      case @format_type
      when 'tree'
        tree_ac=DataStructureFormatter::Tree::Accessor.new
        tree_ac.value_accessor{|node| node.name}
        tree_ac.child_enumerator{|node| node.children}
        tree_fmt=DataStructureFormatter::Tree::Formatter.new tree_ac
        data=[]
        Endpoint.roots.each{|ep| data += tree_fmt.format_array(ep) }
        table_ac=DataStructureFormatter::Table::Accessor.new 
        table_ac.row_enumerator {|data| data }
        table_ac.column_enumerator{|row|
          [row[0].id,row[1],row[0].aliases.map{|a|a.name}.join(',')]
        }
        table_fmt=DataStructureFormatter::Table::Formatter.new(table_ac,['id','endpoint','aliases'])
        table_fmt.format data
      when 'table'
        ac=DataStructureFormatter::Table::Accessor.new
        ac.row_enumerator {|target| target}
        ac.column_enumerator {|row|
          parent_name=row.parent.nil? ? '':row.parent.name
          [row.id,row.name,parent_name,row.aliases.map{|a|a.name}.join(','),row.description]
        }
        fmt=DataStructureFormatter::Table::Formatter.new(ac,['id','name','parent','aliases','descr.'])
        fmt.format(Endpoint.find(:all))
      else
        raise "unknown format type: #{@format_type}. tree|table is acceptable"
      end
    end

    define_command(['transactions','trs'],[ [:range,String,{:default=>nil}], [:endpoint,Endpoint,{:default=>nil}]]) do
      ac=DataStructureFormatter::Table::Accessor.new
      ac.row_enumerator {|data| data}
      ac.column_enumerator {|row|
        [row.id,row.date.to_s,row.src.name,row.dest.name,row.amount,row.description]
      }
      fmt=DataStructureFormatter::Table::Formatter.new ac,['id','date','src','dest','amount','descr.']
      # TODO: separate and testable berrow logic
      today=Date.today
      case @range
      when nil
        start=Date.new(today.year,today.month,1)
        range=start..((start >> 1) - 1)
      when /^(\d{1,2})$/
        month=$1.to_i
        start=Date.new(today.year,month,1)
        range=start..((start >> 1) - 1)
      else
        if Date::MONTHNAMES.include? @range
          month=Date::MONTHNAMES.index @range
          start=Date.new(today.year,month,1)
          range=start..((start >> 1) - 1)
        elsif Date::ABBR_MONTHNAMES.include? @range
          month=Date::ABBR_MONTHNAMES.index @range
          start=Date.new(today.year,month,1)
          range=start..((start >> 1) - 1)
        else
          raise ArgumentError.new("invalid range format: #{@range}")
        end
      end
      range_str="#{range.first.to_s} - #{range.last.to_s}"
      conditions=[]
      #todo: impl it
      conditions << ['date between ?',range]
      conditions << ['endpoint in ?',[@endpoint]+@endpoint.descendants] unless @endpoint.nil?
      body=fmt.format(Transaction.find(:all,:conditions=>nil,:order=>'date'))
      [range_str,body].join("\n")
    end

    define_command(['account_histories','ahs']) do
      ac=DataStructureFormatter::Table::Accessor.new
      ac.row_enumerator {|data| data}
      ac.column_enumerator {|row|
        [row.id,row.date.to_s,row.endpoint.name,row.amount]
      }
      fmt=DataStructureFormatter::Table::Formatter.new ac,['id','date','endpoint','amount']
      fmt.format(AccountHistory.find(:all,:order=>'date'))
    end

    define_command(['balance','b'],[
                     [:year,Numeric,{:default=>nil}],
                     [:month,Numeric,{:default=>nil}],
                     [:date,Numeric,{:default=>nil}],
                     [:endpoint,Endpoint,{:default=>nil}] ]) do
      tree_ac=DataStructureFormatter::Tree::Accessor.new
      tree_ac.value_accessor{|node| node.name}
      tree_ac.child_enumerator{|node| node.children}
      tree_fmt=DataStructureFormatter::Tree::Formatter.new tree_ac

      if @endpoint.nil?
        tree_data=[]
        Endpoint.roots.each{|ep|
          tree_data+=tree_fmt.format_array(ep)
        }
      else
        tree_data=tree_fmt.format_array(@endpoint)
      end

      table_ac=DataStructureFormatter::Table::Accessor.new 
      table_ac.row_enumerator {|data| data }
      table_ac.column_enumerator{|row|
        [row[1], row[0].balance_at(@year,@month,@date)]
      }
      table_fmt=DataStructureFormatter::Table::Formatter.new(table_ac,['endpoint','balance'])
      table_fmt.format tree_data
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
