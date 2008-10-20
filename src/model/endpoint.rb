require File.dirname(__FILE__)+'/'+'../exceptions.rb'

class Endpoint < ActiveRecord::Base
  def amount_at(at)
    raise AccountHistoryNotFoundError
  end
end
