require 'rubygems'
require 'active_record'

require File.dirname(__FILE__)+'/'+'endpoint.rb'

class AccountHistory < ActiveRecord::Base
  belongs_to :endpoint,:class_name=>'Endpoint',:foreign_key=>:endpoint
end
