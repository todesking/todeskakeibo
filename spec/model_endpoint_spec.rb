require 'spec/model_spec_helper.rb'

describe Endpoint,'with no transactions and no account history' do
  before(:all) do
    ModelSpecHelper.setup_database
  end
  before(:each) do
    Endpoint.delete_all
    Transaction.delete_all
    AccountHistory.delete_all
    [
      { :name => 'bank' },
      { :name => 'wallet' },
      { :name => 'food' }
    ].each{|ep|
      Endpoint.new(ep).save
    }
  end
  it 'should raises error when amount_at called if account history is empty' do
    bank=Endpoint.find_by_name 'bank'
    lambda{bank.amount_at(Date.new(2008,10,1))}.should raise_error(AccountHistoryNotFoundError)
  end
end

