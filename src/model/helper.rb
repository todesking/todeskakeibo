require 'rubygems'
require 'active_record'

require File.dirname(__FILE__)+'/'+'../model/transaction.rb'
require File.dirname(__FILE__)+'/'+'../model/account_history.rb'

module ModelHelper
  def self.create_tables
    Transaction.connection.execute 'drop table if exists transactions'
    Transaction.connection.execute <<-'EOS'
      create table transactions (
        id integer not null primary key,
        date date not null,
        src string not null,
        dest string not null,
        amount integer not null,
        description text
      )
    EOS
    AccountHistory.connection.execute 'drop table if exists account_histories'
    AccountHistory.connection.execute <<-'EOS'
      create table account_histories (
        id integer not null primary key,
        date date not null,
        name string not null,
        amount integer not null
      )
    EOS
  end
end
