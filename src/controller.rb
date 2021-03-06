require File.dirname(__FILE__)+'/'+'command/command_parser.rb'
require File.dirname(__FILE__)+'/'+'model/transaction.rb'
require File.dirname(__FILE__)+'/'+'model/endpoint_alias.rb'
require File.dirname(__FILE__)+'/'+'util/date_parser.rb'
require File.dirname(__FILE__)+'/'+'util/data_structure_formatter.rb'
require 'pp'

class Controller
  def type_parser
    @parser.type_parser
  end
  attr_accessor :parser
  attr_reader :date_parser
  def initialize
    @parser=CommandParser.new
    @date_parser=DateParser.new
    parser=@parser
    date_parser=@date_parser
    date_parser.base_date=Date.today

    # define argument types
    @parser.type_parser.define_mapping(Endpoint) {|ep_name|
      ep=Endpoint.lookup(ep_name)
      raise ArgumentError.new("unknown endpoint name: #{ep_name}") if ep.nil?
      ep
    }

    @parser.type_parser.define_mapping(Date) {|date|
      @date_parser.parse(date)
    }

    @parser.type_parser.define_mapping(Transaction) {|id|
      Transaction.find(Integer(id))
    }

    @parser.type_parser.define_mapping([Date,Range]) {|daterange|
      @date_parser.parse_range(daterange)
    }

    # define commands
    define_command(['base_date','bd'],[[:date,Date,{:default=>nil}]]) do
      date_parser.base_date=@date unless @date.nil?
      "base date: #{date_parser.base_date.to_s}"
    end
    @parser.command('bd').description='show/set base date'

    @parser.define_command(['delete','del','rm'],[ [:type,String], [:id,Numeric]]) {
      ac=DataStructureFormatter::Table::Accessor.new
      fmt=nil
      case @type
      when 'transaction','tr'
        table=Transaction
        ac.column_enumerator {|row|
          [row.id,row.date.to_s,row.src.name,row.dest.name,row.amount,row.description]
        }
        fmt=DataStructureFormatter::Table::Formatter.new ac,['id','date','src','dest','amount','descr.']
      when 'account_history','ah'
        table=AccountHistory
        ac.column_enumerator {|row|
          [row.id,row.date.to_s,row.endpoint.name,row.amount]
        }
        fmt=DataStructureFormatter::Table::Formatter.new ac,['id','date','endpoint','amount']
      when 'endpoint','ep'
        table=Endpoint
        ac.column_enumerator {|row|
          [row.id,row.name,row.parent.nil? ? '':row.parent.name,row.aliases.map{|a|a.name}.join(','),row.description]
        }
        fmt=DataStructureFormatter::Table::Formatter.new ac,['id','name','parent','aliases','descr.']
      when 'endpoint_alias','epa'
        table=EndpointAlias
        ac.column_enumerator {|row|
          [row.id,row.name,row.endpoint.name]
        }
        fmt=DataStructureFormatter::Table::Formatter.new ac,['id','name','alias for']
      else
        next 'usage: delete [transaction|account_history|endpoint|endpoint_alias]'
      end
      target=table.find_by_id(@id)
      raise "id #{@id} not found" if target.nil?
      str=fmt.format [target]
      target.destroy
      "#{table.name} \##{target.id} was destroied\n"+str
    }
    @parser.command('del').description='delete specified item'

    define_command(['transaction','tr','t'],[[:date,Date], [:src,Endpoint], [:dest,Endpoint], [:amount,Numeric], [:description,String,{:default=>nil}]]) do
      tr=Transaction.new(:date=>@date, :src=>@src, :dest=>@dest, :amount=>@amount,:description=>@description)
      tr.save
      "transaction \##{tr.id} added."
    end
    @parser.command('tr').description='add transaction'

    define_command(['account','ac','a'],[[:date,Date], [:endpoint,Endpoint], [:amount,Numeric],[:description,String,{:default=>nil}]]) do
      ah=AccountHistory.new(:date=>@date, :endpoint=>@endpoint, :amount=>@amount, :description=>@description)
      ah.save
      "account history \##{ah.id} added"
    end
    @parser.command('a').description='add account history'

    define_command(['endpoint','ep'],[[:ep_name,String],[:parent,Endpoint,{:default=>nil}],[:description,String,{:default=>nil}]]) do
      ep=Endpoint.new(:name=>@ep_name,:parent=>@parent,:description=>@description)
      ep.save
      "enpoint \##{ep.id}(#{ep.name}) added."
    end
    @parser.command('ep').description='add endpoint'

    @parser.define_hierarchical_command(['set',['endpoint','ep']],[ [:target,Endpoint], [:property,String],[:value,String] ]) do
      case @property
      when 'parent='
        @parent=Endpoint.lookup(@value)
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
    @parser.command('set').description='set the item\'s attribute'

    @parser.define_hierarchical_command(['set',['transaction','tr']],[ [:target,Transaction],[:property,String],[:value,String] ]) do
      raise ArgumentError.new("target not found") if @target.nil?
      case @property
      when 'src='
        @target.src=parser.type_parser.parse(@value,Endpoint)
      when 'dest='
        @target.dest=parser.type_parser.parse(@value,Endpoint)
      when 'amount='
        @target.amount=parser.type_parser.parse(@value,Numeric)
      when 'date='
        @target.date=parser.type_parser.parse(@value,Date)
      when 'description='
        @target.description=@value
      else
        raise ArgumentError.new("unknown property: #{@property}")
      end
      @target.save
      "set transaction #{@target.id} #{@property} #{@value}"
    end
    
    define_command(['endpoint_alias','epa'],[[:alias_name,String],[:alias_for,Endpoint]]) do
      epa=EndpointAlias.new(:name=>@alias_name,:endpoint=>@alias_for)
      epa.save
      "endpoint alias \##{epa.id}(#{epa.name} => #{@alias_for.name}) added."
    end
    @parser.command('epa').description='create endpoint aliase name'

    # define commands(untestable, most of is 'show' command)
    define_command(['help','h','he','?'],[ [:arg,String,{:default=>nil}] ]) do
      unless @arg.nil?
        cmd=parser.command(@arg)
        if cmd.nil?
          "help: command #{@arg} is undefined"
        else
          lines=[]
          if parser.aliases_for(cmd).empty?
            lines << "#{cmd.name} #{cmd.arg_defs.to_str}"
          else
            lines << "#{cmd.name}(#{parser.aliases_for(cmd).map{|k,cmd|k}.join(' ')}) #{cmd.arg_defs.to_str}"
          end
          lines << "  #{cmd.description}" unless cmd.description.nil? || cmd.description.empty?
          lines << "sub-commands:" unless cmd.sub_commands.empty?
          cmd.sub_commands.values.map{|c|[c,cmd.sub_commands.reject{|k,v|v!=c||k==c.name}.map{|k,v|k}]}.each{|c,a|
            lines << "  #{cmd.name} #{c.name} #{c.arg_defs.to_str}"
            lines << "    #{c.description}" unless c.description.nil? || c.description.empty?
          }
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
    @parser.command('h').description='show help'

    @parser.define_hierarchical_command(['help',['commands','co']],[]) do
      lines=[]
      lines << 'Commands:'
      parser.non_alias_commands.each{|k,v|
        if parser.aliases_for(v).empty?
          lines << "  #{v.name} #{v.arg_defs.to_str}"
        else
          lines << "  #{v.name}(#{parser.aliases_for(v).map{|k,v|k}.join(' ')}) #{v.arg_defs.to_str}"
        end
        lines << "    #{v.description}" unless v.description.nil? || v.description.empty?
      }
      lines.join("\n")
    end

    define_command(['start-of-month','som'],[ [:date,Numeric,{:default=>nil}] ]) do
      date_parser.start_of_month=@date unless @date.nil?
      "start of month: #{date_parser.start_of_month.to_s}"
    end
    @parser.command('som').description='show/set day of start of month'

    define_command(['missing-transactions','mtrs'],[]) do
      require 'pp'
      ep_ids_in_ah=AccountHistory.connection.execute('select distinct endpoint as endpoint from account_histories').map{|eid|eid['endpoint'].to_i}
      missing=[]
      Endpoint.find(ep_ids_in_ah).each{|ep|
        ahs=AccountHistory.find_all_by_endpoint(ep,:order=>:date)
        (1...ahs.length).each{|i|
          before=ahs[i-1]
          current=ahs[i]
          diff=current.amount - (before.amount+ep.balance(before.date...current.date))
          missing.push([ep.name,current.date-1,diff]) if diff!=0
        }
      }
      next 'nothing' if missing.empty?
      table_ac=DataStructureFormatter::Table::Accessor.new 
      table_fmt=DataStructureFormatter::Table::Formatter.new(table_ac,['endpoint','date','diff'])
      [table_fmt.format(missing),"#{missing.length} items."].join("\n")
    end
    @parser.command('mtrs').description='show missing cacheflow'

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
        table_ac.column_enumerator{|row|
          [row[0].id,row[1],row[0].aliases.map{|a|a.name}.join(',')]
        }
        table_fmt=DataStructureFormatter::Table::Formatter.new(table_ac,['id','endpoint','aliases'])
        table_fmt.format data
      when 'table'
        ac=DataStructureFormatter::Table::Accessor.new
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
    @parser.command('eps').description='show endpoints'

    define_command(['transactions','trs'],[ [:range,[Date,Range],{:default=>nil}], [:endpoint,Endpoint,{:default=>nil}]]) do
      ac=DataStructureFormatter::Table::Accessor.new
      ac.column_enumerator {|row|
        [row.id,row.date.to_s,row.src.name,row.dest.name,row.amount,row.description]
      }
      fmt=DataStructureFormatter::Table::Formatter.new ac,['id','date','src','dest','amount','descr.']
      range_str="#{@range.first.to_s} - #{@range.last.to_s}" if !@range.nil?
      range_str="all" if @range.nil?
      conditions={}
      conditions[:date]=@range if !@range.nil?
      if @endpoint.nil?
        transactions=Transaction.find(:all,:conditions=>conditions,:order=>'date')
      else
        transactions=@endpoint.transactions(@range)
      end
      [range_str,fmt.format(transactions),"#{transactions.length} transactions."].join("\n")
    end
    @parser.command('trs').description='show transactions'

    define_command(['account_histories','ahs']) do
      ac=DataStructureFormatter::Table::Accessor.new
      ac.column_enumerator {|row|
        [row.id,row.date.to_s,row.endpoint.name,row.amount]
      }
      fmt=DataStructureFormatter::Table::Formatter.new ac,['id','date','endpoint','amount']
      ahs=AccountHistory.find(:all,:order=>'date')
      [fmt.format(ahs),"#{ahs.length} items"].join("\n")
    end
    @parser.command('ahs').description='show account histories'

    define_command(['balance','b'],[
                     [:range,[Date,Range],{:default=>nil}],
                     [:endpoint,Endpoint,{:default=>nil}] ]) do
      @range=date_parser.min_date..date_parser.max_date if @range.nil?
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
      table_ac.column_enumerator{|row|
        [row[1], row[0].balance(@range),row[0].expense(@range),row[0].income(@range), row[0].amount_at(@range.first), row[0].amount_at(@range.last)]
      }
      table_fmt=DataStructureFormatter::Table::Formatter.new(table_ac,['endpoint','balance','expense','income','amount(first)','amount(last)'])
      ep_name=@endpoint.nil? ? 'all endpoints' : @endpoint.name
      pp @range.nil?
      range_str=@range.nil? ? "" : "#{@range.first.to_s} - #{@range.last.to_s}"
      ["balance of #{ep_name} #{range_str}",
        table_fmt.format(tree_data)].join("\n")
    end
    @parser.command('b').description='show balance of the endpoint'

    define_command(['estimate','est'],[ [:endpoint,Endpoint] ]) do
      " current amount of #{@endpoint.name} is #{@endpoint.amount_at(Date.today)}"
    end
    @parser.command('est').description='show current amount of the endpoint'
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
