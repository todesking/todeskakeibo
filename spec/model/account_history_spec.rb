require 'spec/model/spec_helper.rb'

describe AccountHistory,'with no history' do
  before(:all) do
    ModelSpecHelper.setup_database
    @wallet=Endpoint.new(:name=>'wallet')
    @wallet.save
    @bank=Endpoint.new(:name=>'bank')
    @bank.save
  end
  before(:each) do
    AccountHistory.delete_all
  end
end

