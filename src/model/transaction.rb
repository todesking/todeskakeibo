require 'rubygems'
require 'active_record'

class Transaction < ActiveRecord::Base
  # note: from,to is Date, inclusive
  def self.balance_between(stash_name,from,to)
    raise ArgumentError.new('from > to') unless from <= to
    expenses=Transaction.sum('amount',:conditions=>['src = ? and ? <= date and date <= ?',stash_name,from,to])
    income=Transaction.sum('amount',:conditions=>['dest = ? and ? <= date and date <= ?',stash_name,from,to])
    return income - expenses
  end
end
