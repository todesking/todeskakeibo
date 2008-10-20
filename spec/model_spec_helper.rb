require File.dirname(__FILE__)+'/'+'../src/model/helper.rb'

module ModelSpecHelper
  def self.setup_database
    ActiveRecord::Base.establish_connection(
      :adapter => 'sqlite3',
      :dbfile => ':memory:'
    )
    ModelHelper.create_tables
  end
  def self.create_nested_endpoints defs
    defs.each{|d|
      name=d.instance_of?(Array)?d[0]:d
      Endpoint.new(:name => name.to_s).save
    }
    defs.each{|d|
      name=d.instance_of?(Array)?d[0]:d
      parent_name=d.instance_of?(Array)?d[1]:nil
      next if parent_name.nil?
      ep=Endpoint.find_by_name(name.to_s)
      parent=Endpoint.find_by_name(parent_name.to_s)
      raise "undefined parent name: #{parent_name}" if parent.nil?
      ep.parent=parent
      ep.save
    }
  end
  def self.create_account_history defs
    defs.each{|d|
      if d.length==5
        year=d.shift
      else
        year=2008
      end
      AccountHistory.new(:date => Date.new(year,d[0],d[1]), :endpoint => d[2], :amount => d[3]).save
    }
  end
  def self.create_transactions defs
    defs.each{|d|
      if d.length==6
        year=d.shift
      else
        year=2008
      end
      Transaction.new(:date=>Date.new(year,d[0],d[1]), :src=>d[2],:dest=>d[3],:amount=>d[4]).save
    }
  end
end
