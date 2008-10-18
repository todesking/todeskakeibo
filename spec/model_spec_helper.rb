require File.dirname(__FILE__)+'/'+'../src/model/helper.rb'

module ModelSpecHelper
  def self.setup_database
    ActiveRecord::Base.establish_connection(
      :adapter => 'sqlite3',
      :dbfile => ':memory:'
    )
    ModelHelper.create_tables
  end
end
