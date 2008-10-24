require 'rubygems'
require 'active_record'

require File.dirname(__FILE__)+'/'+'endpoint.rb'

class Transaction < ActiveRecord::Base
  belongs_to :src,{ :class_name => 'Endpoint', :foreign_key => :src }
  belongs_to :dest,{ :class_name => 'Endpoint', :foreign_key => :dest }
  # note: from,to is Date, inclusive
  def self.balance_between(endpoint,from,to,include_subendpoint=true)
    raise ArgumentError.new('from > to') unless from.nil? || to.nil? || from <= to
    raise ArgumentError.new('endpoint must be Endpoint object') unless endpoint.kind_of? Endpoint

    if include_subendpoint
      return endpoint.descendants.inject(balance_between(endpoint,from,to,false)){|a,d|
        a+balance_between(d,from,to,false)
      }
    end

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
  def self.balance_at(endpoint,year=nil,month=nil,day=nil,include_subendpoint=true)
    raise ArgumentError if endpoint.nil?
    raise ArgumentError('day argument must nil when month==nil') if month.nil? && !day.nil?

    if year.nil?
      balance_between(endpoint,nil,nil,include_subendpoint)
    elsif month.nil?
      balance_between(endpoint,Date.new(year,1,1),Date.new(year+1,1,1)-1,include_subendpoint)
    elsif day.nil?
      balance_between(endpoint,Date.new(year,month,1),(Date.new(year,month,1) >> 1)-1,include_subendpoint)
    else
      balance_between(endpoint,Date.new(year,month,day),Date.new(year,month,day),include_subendpoint)
    end
  end
end
