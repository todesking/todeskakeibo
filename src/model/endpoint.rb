require 'rubygems'
require 'active_record'

require File.dirname(__FILE__)+'/'+'endpoint_alias.rb'
require File.dirname(__FILE__)+'/'+'../util/helper.rb'

class Endpoint < ActiveRecord::Base
  belongs_to :parent,:class_name=>'Endpoint',:foreign_key=>:parent
  has_many :children,:class_name=>'Endpoint',:foreign_key=>:parent
  has_many :aliases,:class_name=>'EndpointAlias',:foreign_key=>:endpoint

  def self.roots
    find(:all,:conditions=>{:parent=>nil})
  end

  def newest_account_history(date)
    raise ArgumentError.new('date must be Date object') unless date.kind_of? Date
    return AccountHistory.find(:first,:conditions=>['endpoint = ? and date <= ?',self,date],:order=>'date desc')
  end
  def amount_at(at)
    history=newest_account_history(at)
    if history.nil?
      return 0 + balance_between(nil,at)
    else
      return history.amount + balance_between(history.date,at)
    end
  end
  def descendants
    result=self.children.to_a
    self.children.each{|c|
      result += c.descendants
    }
    return result
  end
  # note: from,to is Date, inclusive
  def balance_between(from,to,include_subendpoint=true)
    # this is slightly slow maybe, but speed is not matter in this case
    return income_between(from,to,include_subendpoint)-expense_between(from,to,include_subendpoint)
  end
  def balance_at(year=nil,month=nil,day=nil,include_subendpoint=true)
    raise ArgumentError('day argument must nil when month==nil') if month.nil? && !day.nil?

    return balance_between(nil,nil,include_subendpoint) if year.nil?

    range=Helper.create_date_range(year,month,day)
    return balance_between(range.first,range.last,include_subendpoint)
  end
  def income_at(year=nil,month=nil,day=nil,include_subendpoint=true)
    raise ArgumentError('day argument must nil when month==nil') if month.nil? && !day.nil?

    return income_between(nil,nil,include_subendpoint) if year.nil?

    range=Helper.create_date_range(year,month,day)
    return income_between(range.first,range.last,include_subendpoint)
  end
  def expense_at(year=nil,month=nil,day=nil,include_subendpoint=true)
    raise ArgumentError('day argument must nil when month==nil') if month.nil? && !day.nil?

    return expense_between(nil,nil,include_subendpoint) if year.nil?

    range=Helper.create_date_range(year,month,day)
    return expense_between(range.first,range.last,include_subendpoint)
  end
  def transaction_amount(from,to,include_subendpoint,direction)
    raise ArgumentError.new('from > to') unless from.nil? || to.nil? || from <= to

    endpoints=[self]
    endpoints+=descendants if include_subendpoint

    cond_str=case direction
             when :src
              'src in (?) and dest not in(?)'
             when :dest
              'src not in (?) and dest in(?)'
             else
               raise ArgumentError.new('unknown direction')
             end
    cond=[nil,endpoints,endpoints]

    cond_str+=' and ? <= date' unless from.nil?
    cond.push from unless from.nil?

    cond_str+=' and date <= ?' unless to.nil?
    cond.push to unless to.nil?

    cond[0]=cond_str
    return Transaction.sum('amount',:conditions=>cond)
  end
  def income_between(from,to,include_subendpoint=true)
    transaction_amount(from,to,include_subendpoint,:dest)
  end
  def expense_between(from,to,include_subendpoint=true)
    transaction_amount(from,to,include_subendpoint,:src)
  end
  def transactions(date_range=nil)
    if date_range.nil?
      return Transaction.find(:all,:conditions=>['src in (:eps) or dest in (:eps)',{:eps=>[self]+self.descendants}],:order=>:date)
    else
      date_start=date_range.first
      date_end=date_range.last
      date_end-=1 if date_range.exclude_end?
      return [] if date_start > date_end
      Transaction.find(:all,:conditions=>['date between :date_start and :date_end and (src in (:eps) or dest in (:eps))',
                       {:date_start=>date_start,:date_end=>date_end, :eps=>[self]+self.descendants}],:order=>:date)
    end
  end
end
