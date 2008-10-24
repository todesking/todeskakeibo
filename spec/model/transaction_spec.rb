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
  it 'should error when balance_between called with to < from date' do
    lambda {Transaction.balance_between(@bank,Date.new(2008,9,30),Date.new(2008,8,10))}.should raise_error(ArgumentError)
    lambda {Transaction.balance_between(@bank,Date.new(2008,9,30),Date.new(2008,9,29))}.should raise_error(ArgumentError)
    lambda {Transaction.balance_between(@bank,Date.new(2008,9,30),Date.new(2008,9,30))}.should_not raise_error
  end
  it 'should error when balance_between called with non Endpoint object as 1st arg' do
    lambda {Transaction.balance_between('bank',Date.new(2008,9,30),Date.new(2008,10,1))}.should raise_error(ArgumentError)
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
  it 'should return 0 when balance_between called' do
    Transaction.balance_between(@bank,Date.new(2008,10,1),Date.new(2008,12,1)).should be == 0
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
  def assert_balance_between(name,from,to,expected_balance)
    Transaction.balance_between(name,from,to).should be == expected_balance
  end

  it 'should -10000 balance at bank and +10000 at wallet at 9-29' do
    a=Date.new(2008,9,29)
    b=Date.new(2008,9,29)
    assert_balance_between(@bank       , a , b , -10000 )
    assert_balance_between(@wallet     , a , b , +10000 )
    assert_balance_between(@food       , a , b , 0      )
    assert_balance_between(@house_rent , a , b , 0      )
    assert_balance_between(@office     , a , b , 0      )
  end
  it 'should right balance at 9-29 to 9-30' do
    a=Date.new(2008,9,29)
    b=Date.new(2008,9,30)
    assert_balance_between(@bank       , a , b , -10000 )
    assert_balance_between(@wallet     , a , b , +8000  )
    assert_balance_between(@food       , a , b , +2000  )
    assert_balance_between(@house_rent , a , b , 0      )
    assert_balance_between(@office     , a , b , 0      )
  end
  it 'should right balance at 9-29 to 10-01' do
    a=Date.new(2008,9,29)
    b=Date.new(2008,10,1)
    assert_balance_between(@bank       , a , b , +10000 )
    assert_balance_between(@wallet     , a , b , -12000 )
    assert_balance_between(@food       , a , b , +2000  )
    assert_balance_between(@house_rent , a , b , 0      )
    assert_balance_between(@office     , a , b , 0      )
  end
  it 'should right balance at 9-29 to 10-02' do
    a=Date.new(2008,9,29)
    b=Date.new(2008,10,2)
    assert_balance_between(@bank       , a , b , +45000  )
    assert_balance_between(@wallet     , a , b , +3000   )
    assert_balance_between(@food       , a , b , +2000   )
    assert_balance_between(@house_rent , a , b , +50000  )
    assert_balance_between(@office     , a , b , -100000 )
  end
  it 'should right balance at 9-29 to 10-03, its same as 9-29 to 10-02' do
    a=Date.new(2008,9,29)
    b=Date.new(2008,10,3)
    assert_balance_between(@bank       , a , b , +45000  )
    assert_balance_between(@wallet     , a , b , +3000   )
    assert_balance_between(@food       , a , b , +2000   )
    assert_balance_between(@house_rent , a , b , +50000  )
    assert_balance_between(@office     , a , b , -100000 )
  end
  it 'should right balance at 9-29 to 10-04' do
    a=Date.new(2008,9,29)
    b=Date.new(2008,10,4)
    assert_balance_between(@bank       , a , b , +45000  )
    assert_balance_between(@wallet     , a , b , +500    )
    assert_balance_between(@food       , a , b , +4500   )
    assert_balance_between(@house_rent , a , b , +50000  )
    assert_balance_between(@office     , a , b , -100000 )
  end
  it 'should accept nil for from and to argument' do
    assert_balance_between(@bank ,  nil                 ,  Date.new(2008,10,4 ) ,  +45000)
    assert_balance_between(@bank ,  Date.new(2008,10,3) ,  nil                  ,  0     )
    assert_balance_between(@bank ,  Date.new(2008,10,2) ,  nil                  ,  35000)
  end

end

describe Transaction,'with nested endpoint' do
  before(:all) do
    ModelSpecHelper.setup_database
  end
  before(:each) do
    Endpoint.delete_all
    ModelSpecHelper.create_nested_endpoints [
      :stash,
      [:bank,:stash],
      [:wallet,:stash],
      :income,
      [:company,:income],
      :expense,
      [:food,:expense],
      [:eatout,:expense],
      [:transfer,:expense],
      [:item,:expense],
      [:utility_bill,:expense],
      [:electricity_bill,:utility_bill]
    ]
    ModelSpecHelper.import_endpoints self
    Transaction.delete_all
    ModelSpecHelper.create_transactions [
      [10,1,@bank,@wallet,20000],
      [10,1,@wallet,@food,2000],
      [10,2,@wallet,@eatout,800],
      [10,3,@wallet,@eatout,500],
      [10,10,@bank,@wallet,10000],
      [10,10,@wallet,@eatout,700],
      [10,10,@wallet,@eatout,300],
      [10,11,@wallet,@expense,1000],
      [10,15,@company,@bank,100000],
      [10,16,@bank,@wallet,20000],
      [10,18,@wallet,@transfer,10000],
      [10,19,@wallet,@utility_bill,5000],
      [10,20,@wallet,@electricity_bill,2000],
      [11,1,@bank,@wallet,20000],
      [11,15,@company,@bank,100000],
      [11,16,@wallet,@eatout,1000],
      [11,18,@wallet,@transfer,10000],
      [11,20,@bank,@wallet,30000],
      [2009,1,1,@bank,@wallet,10000],
      [2009,1,3,@wallet,@food,2000],
      [2009,1,15,@company,@bank,150000]
    ]
    AccountHistory.delete_all
    ModelSpecHelper.create_account_history [
      [10,1,@bank,200000],
      [10,1,@wallet,1000],
      [10,5,@bank,180000], # exactly
      [10,5,@wallet,17000], # unrecorded 700 jpy
      [11,1,@bank,100000],
      [11,1,@wallet,3000],
      [2009,1,5,@bank,10000],
      [2009,1,5,@wallet,10000]
    ]
  end
  it 'should returns expense endpoint\'s balance between 10-10 to 10-15(sub endpoint is excluded)' do
    Transaction.balance_between(@expense,Date.new(2008,10,10),Date.new(2008,10,15),false).should be == 1000
  end
  it 'should returns expense endpoint\'s balance between 10-10 to 10-15(sub endpoint is included)' do
    Transaction.balance_between(@expense,Date.new(2008,10,10),Date.new(2008,10,15),true).should be == 2000
    Transaction.balance_between(@expense,Date.new(2008,10,10),Date.new(2008,10,15)).should be == 2000
    Transaction.balance_between(@stash,Date.new(2008,10,10),Date.new(2008,10,15)).should be == 98000
  end
  it 'should returns expense endpoint\'s balance between 10-10 to 10-15(sub endpoint is included)' do
    Transaction.balance_between(@expense,Date.new(2008,10,10),Date.new(2008,10,15),true).should be == 2000
  end
  it 'should returns balance of specified day/month/year' do
    Transaction.balance_at(@wallet,2009).should be == +8000
    Transaction.balance_at(@wallet,2008,11).should be == +39000
    Transaction.balance_at(@wallet,2008,10,10).should be == +9000
    Transaction.balance_at(@wallet,2009,1,3).should be == -2000
    Transaction.balance_at(@wallet).should == 74700
  end
end
