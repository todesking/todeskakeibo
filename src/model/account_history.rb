require 'rubygems'
require 'active_record'

class AccountHistory < ActiveRecord::Base
  def self.newest_history(stash_name, date_before)
    return find(:first,:conditions=>['name = ? and date <= ?',stash_name,date_before],:order=>'date desc')
  end
end
