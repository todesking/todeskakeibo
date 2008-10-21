require 'rubygems'
require 'active_record'

require File.dirname(__FILE__)+'/'+'endpoint.rb'

class AccountHistory < ActiveRecord::Base
  def self.newest_history(endpoint, date)
    raise ArgumentError.new('endpoint must be Endpoint object') unless endpoint.kind_of? Endpoint
    raise ArgumentError.new('date must be Date object') unless date.kind_of? Date
    return find(:first,:conditions=>['endpoint = ? and date <= ?',endpoint,date],:order=>'date desc')
  end
end
