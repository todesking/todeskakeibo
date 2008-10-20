require 'spec/model/spec_helper.rb'

describe EndpointAlias,'when empty' do
  before(:each) do
  end
  it 'should return nil for any name' do
    EndpointAlias.lookup('hoge').should be_nil
  end
end

describe EndpointAlias,'when some aliases' do
  before(:each) do
    Endpoint.delete_all
    ModelSpecHelper.create_nested_endpoints [
      :stash,
      [:wallet,:stash],
      [:bank,:stash]
    ]
    Endpoint.find(:all).each{|ep|
      instance_variable_set('@'+ep.name,ep)
    }
    EndpointAlias.delete_all
    ModelSpecHelper.create_endpoint_aliases [
      [:wa,@wallet],
      [:w,@wallet],
      [:b,@bank]
    ]
  end
  it 'should lookup correct endpoint' do
    EndpointAlias.lookup('wa').should be == @wallet
    EndpointAlias.lookup('w').should be == @wallet
    EndpointAlias.lookup('b').should be == @bank
  end
end
