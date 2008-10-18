require 'spec/model_spec_helper.rb'

describe AccountHistory,'with empty, and no transactions' do
  before(:all) do
    ModelSpecHelper.setup_database
  end
  before(:each) do
    AccountHistory.delete_all
    Transaction.delete_all
  end
  it 'should no amount in any account' do
    AccountHistory.current_amount(:bank).should be(0)
    AccountHistory.current_amount(:wallet).should be(0)
  end
end

describe AccountHistory,'with some histories, and no transactions' do
  before(:all) do
    ModelSpecHelper.setup_database
  end
  before(:each) do
    AccountHistory.delete_all
    Transaction.delete_all
    [
      { :date => '2008-10-01', :name => 'bank', :amount => 1000},
      { :date => '2008-10-02', :name => 'bank', :amount => 2000},
      { :date => '2008-10-03', :name => 'bank', :amount => 3000},
      { :date => '2008-10-04', :name => 'bank', :amount => 1500}
    ].each{|t|
      AccountHistory.new(t).save
    }
  end
  it 'should 0 yen in bank before history begins' do
    AccountHistory.amount_at(:bank,'2008-09-30').should be(0)
    AccountHistory.amount_at(:bank,'2007-10-03').should be(0)
  end
end

describe AccountHistory,'with no histories, and some transactions' do
  before(:all) do
    ModelSpecHelper.setup_database
  end
  before(:each) do
    AccountHistory.delete_all
    Transaction.delete_all
  end
end
