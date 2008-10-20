class EndpointAlias < ActiveRecord::Base
  belongs_to :endpoint,:class_name=>'Endpoint',:foreign_key=>:endpoint
  def self.lookup(name)
    a=EndpointAlias.find_by_name(name)
    return nil if a.nil?
    return a.endpoint
  end
end
