require 'rubygems'
require 'active_record'

class AccountHistory < ActiveRecord::Base
  def self.current_amount(stash_name)
    amount_at(stash_name,Date.new)
  end
  def self.amount_at(stash_name,date)
    most_recent_history=AccountHistory.find(:first,:conditions=>['date < ?',date])
    return 0 if most_recent_history.nil?
    return most_recent_history.amount
  end
end
