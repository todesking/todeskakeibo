start=Time.now
puts 'loading libs...'
require 'rubygems'
require 'activerecord'
require 'kconv'
puts 'loading controller...'
require File.dirname(__FILE__)+'/'+'controller.rb'
puts 'loading model...'
require File.dirname(__FILE__)+'/'+'model/helper.rb'
puts "loading time: #{Time.now-start}"
puts

def in_filter str
  Kconv.toutf8 str
end

def out_filter str
  return str.map{|s|Kconv.tosjis s} if str.instance_of? Array
  return Kconv.tosjis str
end

ActiveRecord::Base.establish_connection(
  :adapter => 'sqlite3',
  :dbfile => './kakeibo.sqlite3'
)

controller=Controller.new

continue=true
verbose_error=false

controller.define_command('exit',[]) { continue=false;'bye.' }
controller.define_command('initialize_database',[]) {
  ModelHelper.create_tables
  'done.'
}
controller.define_command(['verbose_error','ve'],[[:enable,String,{:default=>nil}]]) do
  case @enable
  when 'true'
    verbose_error=true
  when 'false'
    verbose_error=false
  when nil
    # do nothing but return current status
  else
    raise 'wtf?!?!'
  end
  verbose_error
end

while(continue)
  print 'kakeibo> '
  cmd=in_filter gets
  begin
    resp=controller.execute(cmd)
    resp_str=(resp.respond_to? :to_str)? resp.to_str : resp.to_s
    puts out_filter(resp_str.split("\n").map{|l|'  '+l})
  rescue => e
    puts 'ERRORR: '
    str=(e.respond_to? :to_str)? e.to_str : e.to_s
    str+="\n"+e.backtrace.join("\n") if verbose_error
    puts out_filter(str.split("\n").map{|l|'  '+l})
  end
end
