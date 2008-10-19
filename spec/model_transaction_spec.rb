require 'spec/model_spec_helper.rb'

describe Transaction,'in common' do
  before(:all) do
    ModelSpecHelper.setup_database
  end
  before(:each) do
    Transaction.delete_all
  end
  it 'should can store data' do
    Transaction.find(:all).length.should be == 0
    Transaction.new(
      :date => '2008-10-18',
      :src => :bank,
      :dest => :wallet,
      :amount => 1000,
      :description => 'hoge'
    ).save
    Transaction.find(:all).length.should be == 1
    Transaction.find(:first).amount.should be == 1000
  end
  it 'should can store transactions that have no description' do
    Transaction.new(
      :date => '2008-10-18',
      :src => :bank,
      :dest => :wallet,
      :amount => 1000
    ).save
  end
  it 'should error when balance_between called with to < from date' do
    lambda {Transaction.balance_between('bank',Date.new(2008,9,30),Date.new(2008,8,10))}.should raise_error(ArgumentError)
    lambda {Transaction.balance_between('bank',Date.new(2008,9,30),Date.new(2008,9,29))}.should raise_error(ArgumentError)
    lambda {Transaction.balance_between('bank',Date.new(2008,9,30),Date.new(2008,9,30))}.should_not raise_error(ArgumentError)
  end
end

describe Transaction,'when no transactions' do
  before(:all) do
    ModelSpecHelper.setup_database
  end
  before(:each) do
    Transaction.delete_all
  end
  it 'should return 0 when balance_between called' do
    Transaction.balance_between('bank',Date.new(2008,10,1),Date.new(2008,12,1)).should be == 0
  end
end
describe Transaction,'when some transactions' do
  before(:all) do
    ModelSpecHelper.setup_database
  end
  before(:each) do
    Transaction.delete_all
    [
      { :date => Date.new(2008,9,30), :src => 'bank', :dest => 'wallet', :amount => 10000, :description=>'withdraw 10000 yen'},
      { :date => Date.new(2008,9,30), :src => 'bank', :dest => 'wallet', :amount => 10000, :description=>'withdraw 10000 yen'},
      { :date => Date.new(2008,9,30), :src => 'bank', :dest => 'wallet', :amount => 10000, :description=>'withdraw 10000 yen'},
      { :date => Date.new(2008,9,30), :src => 'bank', :dest => 'wallet', :amount => 10000, :description=>'withdraw 10000 yen'},
      { :date => Date.new(2008,9,30), :src => 'bank', :dest => 'wallet', :amount => 10000, :description=>'withdraw 10000 yen'}
    ].each {|t|
      Transaction.new(t).save
    }
  end
end
