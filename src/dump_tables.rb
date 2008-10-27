unless $*.length==2
  puts <<EOS
usage: #$0 target_db dest_prefix
  dump kakeibo tables to TSVs
EOS
  exit
end

target_db=$*[0]
dest_prefix=$*[1]

require 'rubygems'
require 'activerecord'
%w{transaction account_history endpoint endpoint_alias}.each{|req|
  require File.join(File.dirname(__FILE__),'model',req)
}

def dump(writer,table)
  table.find(:all).each{|row|
    writer.puts table.columns.map{|c|c.name}.map{|cn|row[cn]}.join("\t")
  }
end

ActiveRecord::Base.establish_connection(
  :adapter=>'sqlite3',
  :dbfile=>target_db
)

[
  Transaction,
  AccountHistory,
  Endpoint,
  EndpointAlias
].each{|t|
  puts "dumping #{t.name}..."
  writer=open(dest_prefix+t.name+'.tsv','w')
  dump(writer,t)
}
