require 'spec/model/spec_helper.rb'

describe Transaction,'in common' do
  before(:all) do
    ModelSpecHelper.setup_database
  end
  before(:each) do
    Transaction.delete_all
    Endpoint.delete_all
    ModelSpecHelper.create_nested_endpoints [
      :bank, :wallet, :food, :house_rent, :office
    ]
    ModelSpecHelper.import_endpoints self
  end
  it 'should can store data' do
    Transaction.find(:all).length.should be == 0
    Transaction.new(
      :date => '2008-10-18',
      :src => @bank,
      :dest => @wallet,
      :amount => 1000,
      :description => 'hoge'
    ).save
    Transaction.find(:all).length.should be == 1
    Transaction.find(:first).amount.should be == 1000
  end
  it 'should can store transactions that have no description' do
    Transaction.new(
      :date => '2008-10-18',
      :src => @bank,
      :dest => @wallet,
      :amount => 1000
    ).save
  end
  it 'should accept nil for src/dest' do
    Transaction.new(
      :date => '2008-10-18',
      :src => nil,
      :dest => @wallet,
      :amount => 1000
    ).save
    Transaction.new(
      :date => '2008-10-18',
      :src => @bank,
      :dest => nil,
      :amount => 2000
    ).save
    Transaction.find(1).amount.should == 1000
    Transaction.find(2).amount.should == 2000
  end
end

describe Transaction,'when no transactions' do
  before(:all) do
    ModelSpecHelper.setup_database
  end
  before(:each) do
    Transaction.delete_all
    Endpoint.delete_all
    @bank=Endpoint.new(:name=>'bank')
    @bank.save
  end
end

describe Transaction,'when some transactions' do
  before(:all) do
    ModelSpecHelper.setup_database
  end
  before(:each) do
    Endpoint.delete_all
    ModelSpecHelper.create_nested_endpoints [
      :bank, :wallet, :food, :house_rent, :office
    ]
    ModelSpecHelper.import_endpoints self
    Transaction.delete_all
    ModelSpecHelper.create_transactions [
      [9,29,@bank,@wallet,10000],
      [9,30,@wallet,@food,2000],
      [10,1,@wallet,@bank,20000],
      [10,2,@office,@bank,100000],
      [10,2,@bank,@house_rent,50000],
      [10,2,@bank,@wallet,15000],
      [10,4,@wallet,@food,2500]
    ]
  end

  it 'should return proper Endpoint object when src/dest called' do
    t=Transaction.find(:first,:conditions=>{:id=>1})
    t.date.should be == Date.new(2008,9,29)
    t.amount.should be == 10000
    t.src.should_not be_nil
    t.dest.should_not be_nil
    t.src.name.should be == 'bank'
    t.dest.name.should be == 'wallet'
  end
end
