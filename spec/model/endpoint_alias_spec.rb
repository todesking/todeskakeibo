require 'spec/model/spec_helper.rb'

describe EndpointAlias,'when empty' do
  before(:each) do
  end
  it 'should return nil for any name' do
    EndpointAlias.lookup('hoge').should be_nil
  end
end
