require 'spec/model_spec_helper.rb'

describe Endpoint,'with no transactions and no account history' do
  before(:all) do
    ModelSpecHelper.setup_database
  end
  before(:each) do
    Endpoint.delete_all
    [
      { :name => 'bank' },
      { :name => 'wallet' },
      { :name => 'food' }
    ].each{|ep|
      Endpoint.new(ep).save
    }
    Transaction.delete_all
    AccountHistory.delete_all
  end
  it 'should returns 0 when amount_at called if account history is empty' do
    bank=Endpoint.find_by_name 'bank'
    bank.should_not be_nil
    bank.amount_at(Date.new(2008,10,1)).should be == 0
  end
end

describe Endpoint,'with some account history' do
  before(:all) do
    ModelSpecHelper.setup_database
  end
  before(:each) do
    Endpoint.delete_all
    [
      { :name => 'bank' },
      { :name => 'wallet' },
      { :name => 'food' }
    ].each{|ep|
      Endpoint.new(ep).save
    }
    Transaction.delete_all
    AccountHistory.delete_all
    [
      { :date => '2008-10-1', :name => 'bank', :amount => 10000 },
      { :date => '2008-10-2', :name => 'wallet', :amount => 2000 },
      { :date => '2008-10-3', :name => 'wallet', :amount => 20000 },
      { :date => '2008-10-3', :name => 'wallet', :amount => 4000 }
    ].each{|ah|
      AccountHistory.new(ah).save
    }
  end
end
