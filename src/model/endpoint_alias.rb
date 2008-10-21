require 'rubygems'
require 'active_record'

require File.dirname(__FILE__)+'/'+'endpoint.rb'

class EndpointAlias < ActiveRecord::Base
  belongs_to :endpoint,:class_name=>'Endpoint',:foreign_key=>:endpoint
  def self.lookup(name)
    endpoint=nil
    a=EndpointAlias.find_by_name(name)
    return Endpoint.find_by_name(name) if a.nil?
    return a.endpoint
  end
end
