require 'rubygems'
require 'active_record'

class Transaction < ActiveRecord::Base
    def self.balance_between(stash_name,from,to)
        0
    end
end
