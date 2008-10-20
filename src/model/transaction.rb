require 'rubygems'
require 'active_record'

class Transaction < ActiveRecord::Base
  belongs_to :src,{ :class_name => 'Endpoint', :foreign_key => :src }
  belongs_to :dest,{ :class_name => 'Endpoint', :foreign_key => :dest }
  # note: from,to is Date, inclusive
  def self.balance_between(endpoint,from,to,include_subendpoint=false)
    raise ArgumentError.new('from > to') unless from.nil? || to.nil? || from <= to
    raise ArgumentError.new('endpoint must be Endpoint object') unless endpoint.kind_of? Endpoint

    return endpoint.descendants.inject(balance_between(endpoint,from,to)){|a,d| a+balance_between(d,from,to)} if include_subendpoint

    cond_str='%s = ?'
    cond_str+=' and ? <= date' unless from.nil?
    cond_str+=' and date <= ?' unless to.nil?
    cond=['dummy']
    cond.push endpoint
    cond.push from unless from.nil?
    cond.push to unless to.nil?
    cond[0]=cond_str%'src'
    expenses=Transaction.sum('amount',:conditions=>cond)
    cond[0]=cond_str%'dest'
    income=Transaction.sum('amount',:conditions=>cond)
    return income - expenses
  end
  def self.balance_at(endpoint,year,month=nil,day=nil)
    raise ArgumentError if endpoint.nil?
    raise ArgumentError if year.nil?
    raise ArgumentError('day argument must nil when month==nil') if month.nil? && !day.nil?

    if(month.nil?)
      date_cond='%04d-%%' % [year]
    elsif day.nil?
      date_cond='%04d-%02d-%%' % [year,month]
    elsif
      date_cond='%04d-%02d-%02d' % [year,month,day]
    end

    expenses=Transaction.sum(:amount,:conditions=>['src = ? and date like ?',endpoint,date_cond])
    income=Transaction.sum(:amount,:conditions=>['dest = ? and date like ?',endpoint,date_cond])
    return income-expenses
  end
end
