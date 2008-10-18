require 'rubygems'
require 'active_record'

class AccountHistory < ActiveRecord::Base
  def self.current_amount(stash_name)
    amount_at(stash_name,Date.new)
  end
  def self.amount_at(stash_name,date)
    0
  end
end
