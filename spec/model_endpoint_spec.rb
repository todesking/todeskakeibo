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

describe Endpoint,'with some account histories and some transactions' do
  before(:all) do
    ModelSpecHelper.setup_database
  end
  before(:each) do
    Endpoint.delete_all
    [
      { :name => 'bank' },
      { :name => 'wallet' },
      { :name => 'food' },
      { :name => 'house_rent' }
    ].each{|ep|
      endpoint=Endpoint.new(ep)
      endpoint.save
      instance_variable_set('@'+ep[:name],endpoint)
    }
    Transaction.delete_all
    [
      { :date => '2008-9-30', :src => @bank, :dest => @house_rent,:amount=>50000 },
      { :date => '2008-10-3', :src => @bank, :dest => @wallet, :amount => 5000 }
    ].each{|t|
      Transaction.new(t).save
    }
    AccountHistory.delete_all
    [
      { :date => '2008-10-1', :endpoint => @bank, :amount => 10000 },
      { :date => '2008-10-2', :endpoint => @wallet, :amount => 2000 },
      { :date => '2008-10-3', :endpoint => @bank, :amount => 20000 },
      { :date => '2008-10-4', :endpoint => @wallet, :amount => 4000 }
    ].each{|ah|
      AccountHistory.new(ah).save
    }
    @bank.should_not be_nil
    @bank.name.should be == 'bank'
  end
  it 'should error when amount_at called with non Date object as 1st arg' do
    lambda{@bank.amount_at('2008-10-1')}.should raise_error(ArgumentError)
  end
  it 'should has null parent by default' do
    @bank.parent.should be_nil
  end
  it 'should can set parent Endpoint' do
    #this is meaningless code
    @bank.parent=@wallet
    @bank.parent.name.should be == 'wallet'
  end
  it 'should returns collect amount at 9-29' do
    date=Date.new(2008,9,29)
    @bank.amount_at(date).should be == 0
    @wallet.amount_at(date).should be == 0
    @food.amount_at(date).should be == 0
  end
  it 'should returns collect amount at 9-30' do
    date=Date.new(2008,9,30)
    @bank.amount_at(date).should be == -50000
    @wallet.amount_at(date).should be == 0
    @food.amount_at(date).should be == 0
  end
  it 'should returns collect amount at 10-1' do
    date=Date.new(2008,10,1)
    @bank.amount_at(date).should be == 10000
    @wallet.amount_at(date).should be == 0
    @food.amount_at(date).should be == 0
  end
  it 'should returns collect amount at 10-2' do
    date=Date.new(2008,10,2)
    @bank.amount_at(date).should be == 10000
    @wallet.amount_at(date).should be == 2000
    @food.amount_at(date).should be == 0
  end
  it 'should returns collect amount at 10-3' do
    date=Date.new(2008,10,3)
    @bank.amount_at(date).should be == 15000
    @wallet.amount_at(date).should be == 7000
  end
end

describe Endpoint,'with nested' do
  before(:all) do
    ModelSpecHelper.setup_database
  end
  before(:each) do
    Endpoint.delete_all
    [
      {:name => 'stash'},
      {:name => 'bank'},
      {:name => 'expanse'},
      {:name => 'utility_bill'},
      {:name => 'electricity_bill'},
      {:name => 'food'}
    ].each{|ep|
      endpoint=Endpoint.new(ep)
      endpoint.save
      instance_variable_set('@'+ep[:name],endpoint)
    }
    @bank.parent=@stash
    @utility_bill.parent=@expanse
    @electricity_bill.parent=@utility_bill
    @food.parent=@expanse
    [@bank,@utility_bill,@electricity_bill,@food].each{|ep|ep.save}
  end
  it 'should be returns collect parent' do
    @bank.parent.should be == @stash
    @electricity_bill.parent.should be == @utility_bill
    @electricity_bill.parent.parent.should be == @expanse
  end
  it 'should be returns collect children' do
    @bank.children.length.should be == 0
    @utility_bill.children.length.should be == 1
    @utility_bill.children[0].should be == @electricity_bill
  end
  it 'should be returns all descendants' do
    @electricity_bill.descendants.length.should be == 0
    @expanse.descendants.length.should be == 3
    @expanse.descendants.include?(@food).should be_true
    @expanse.descendants.include?(@utility_bill).should be_true
    @expanse.descendants.include?(@electricity_bill).should be_true
  end
end
