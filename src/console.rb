puts 'loading...'
require 'rubygems'
require 'activerecord'

require File.dirname(__FILE__)+'/'+'controller.rb'
require File.dirname(__FILE__)+'/'+'model/helper.rb'

ActiveRecord::Base.establish_connection(
  :adapter => 'sqlite3',
  :dbfile => ':memory:'
)

controller=Controller.new

continue=true

controller.define_command('exit',[]) { continue=false;'bye.' }
controller.define_command('initialize_database',[]) {
  ModelHelper.create_tables
  'done.'
}

while(continue)
  print 'kakeibo> '
  cmd=gets
  begin
    resp=controller.execute(cmd)
    puts ' => '+resp.to_s
  rescue => e
    puts 'ERRORR: '+e
  end
end
