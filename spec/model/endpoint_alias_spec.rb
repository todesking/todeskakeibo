require 'spec/model/spec_helper.rb'

describe EndpointAlias,'when empty' do
  before(:all) do
    ModelSpecHelper.setup_database
  end
  before(:each) do
  end
  it 'should return nil for any name' do
    EndpointAlias.lookup('hoge').should be_nil
  end
end

describe EndpointAlias,'when some aliases' do
  before(:all) do
    ModelSpecHelper.setup_database
  end
  before(:each) do
    Endpoint.delete_all
    ModelSpecHelper.create_nested_endpoints [
      :stash,
      [:wallet,:stash],
      [:bank,:stash]
    ]
    ModelSpecHelper.import_endpoints self
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
  it 'should lookup endpoint by endpoint\'s real name(not alias name)' do
    EndpointAlias.lookup('wallet').should be == @wallet
  end
  it 'should return nil when unknown alias/real name passed' do
    EndpointAlias.lookup('hage').should be_nil
  end
end
