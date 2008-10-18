require 'rubygems'
require 'active_record'

class AccountHistory < ActiveRecord::Base
  def self.current_amount(stash_name)
    0
  end
end
