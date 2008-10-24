require 'rubygems'
require 'active_record'

require File.dirname(__FILE__)+'/'+'endpoint.rb'

class Transaction < ActiveRecord::Base
  belongs_to :src,{ :class_name => 'Endpoint', :foreign_key => :src }
  belongs_to :dest,{ :class_name => 'Endpoint', :foreign_key => :dest }
end
