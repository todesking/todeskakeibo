require 'rubygems'
require 'active_record'

class AccountHistory < ActiveRecord::Base
  def self.newest_history(stash_name, date)
    return find(:first,:conditions=>['name = ? and date <= ?',stash_name,date],:order=>'date desc')
  end
end
