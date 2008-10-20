require 'spec/model_spec_helper.rb'

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
    Endpoint.find(:all).each{|ep|
      instance_variable_set('@'+ep.name,ep)
    }
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
    Endpoint.find(:all).each{|ep|
      instance_variable_set('@'+ep.name,ep)
    }
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
describe Transaction,'with real data' do
  before(:all) do
    ModelSpecHelper.setup_database
  end
  before(:each) do
    Endpoint.delete_all
    ModelSpecHelper.create_nested_endpoints [
      :bank, :wallet, :food, :house_rent, :office
    ]
    Endpoint.find(:all).each{|ep|
      instance_variable_set('@'+ep.name,ep)
    }
    Transaction.delete_all
    [
      { :date => Date.new(2008 , 9  , 29) , :src => @bank   , :dest => @wallet     , :amount => 10000  },
      { :date => Date.new(2008 , 9  , 30) , :src => @wallet , :dest => @food       , :amount => 2000   },
      { :date => Date.new(2008 , 10 , 1)  , :src => @wallet , :dest => @bank       , :amount => 20000  },
      { :date => Date.new(2008 , 10 , 2)  , :src => @office , :dest => @bank       , :amount => 100000 },
      { :date => Date.new(2008 , 10 , 2)  , :src => @bank   , :dest => @house_rent , :amount => 50000  },
      { :date => Date.new(2008 , 10 , 2)  , :src => @bank   , :dest => @wallet     , :amount => 15000  },
      { :date => Date.new(2008 , 10 , 4)  , :src => @wallet , :dest => @food       , :amount => 2500   }
    ].each {|t|
      Transaction.new(t).save
    }
  end
end
