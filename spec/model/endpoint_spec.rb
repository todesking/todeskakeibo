require 'spec/model/spec_helper.rb'

describe Endpoint,'when empty' do
  before(:all) do
    ModelSpecHelper.setup_database
  end
  it '.roots should []' do
    Endpoint.roots.should == []
  end
  it '#lookup should return nil for any name' do
    Endpoint.lookup('hoge').should be_nil
  end
end

describe Endpoint,'with aliases' do
  before(:all) do
    ModelSpecHelper.setup_database
  end
  before(:each) do
    Endpoint.delete_all
    ModelSpecHelper.create_nested_endpoints [
      :stash,
      [:wallet,:stash],
      [:bank,:stash]
    ]
    ModelSpecHelper.import_endpoints self
    EndpointAlias.delete_all
    ModelSpecHelper.create_endpoint_aliases [
      [:wa,@wallet],
      [:w,@wallet],
      [:b,@bank]
    ]
  end
  it 'should lookup correct endpoint' do
    Endpoint.lookup('wa').should be == @wallet
    Endpoint.lookup('w').should be == @wallet
    Endpoint.lookup('b').should be == @bank
  end
  it 'should lookup endpoint by endpoint\'s real name(not alias name)' do
    Endpoint.lookup('wallet').should be == @wallet
  end
  it 'should return nil when unknown alias/real name passed' do
    Endpoint.lookup('hage').should be_nil
  end
end

describe Endpoint,'with some entries' do
  before(:all) do
    ModelSpecHelper.setup_database
  end
  before(:each) do
    Endpoint.delete_all
    ModelSpecHelper.create_nested_endpoints [
      :stash,
      [:bank,:stash],
      [:wallet,:stash],
      :expense,
      :income,
      [:salary,:income]
    ]
    ModelSpecHelper.import_endpoints self
    EndpointAlias.delete_all
    ModelSpecHelper.create_endpoint_aliases [
      [:b,@bank],
      [:w,@wallet]
    ]
  end
  it '.roots should return root entries' do
    Endpoint.roots.length.should == 3
    Endpoint.roots.should be_include(@stash)
    Endpoint.roots.should_not be_include(@salary)
  end
  it '#aliases should return its aliases' do
    @stash.aliases.should be_empty
    @bank.aliases.length.should == 1
    @bank.aliases.first.name.should == 'b'
  end
end

describe Endpoint,'with no transactions and no account history' do
  before(:all) do
    ModelSpecHelper.setup_database
  end
  before(:each) do
    Endpoint.delete_all
    ModelSpecHelper.create_nested_endpoints [
      :food,:wallet,:bank
    ]
    ModelSpecHelper.import_endpoints self
    Transaction.delete_all
    AccountHistory.delete_all
  end
  it 'should returns 0 when amount_at called if account history is empty' do
    @bank.amount_at(Date.new(2008,10,1)).should be == 0
  end
  it '#balance should error when called with argument to < from' do
    lambda {@bank.balance(Date.new(2008,9,30)..Date.new(2008,8,10))}.should raise_error(ArgumentError)
    lambda {@bank.balance(Date.new(2008,9,30)..Date.new(2008,9,29))}.should raise_error(ArgumentError)
    lambda {@bank.balance(Date.new(2008,9,30)..Date.new(2008,9,30))}.should_not raise_error
  end
  it '#balance should return 0' do
    @bank.balance(Date.new(2008,10,1),Date.new(2008,12,1)).should be == 0
  end
  it '#newest_account_history should no amount in any account and any time' do
    @wallet.newest_account_history(Date.new(2007,1,1)).should be_nil
    @bank.newest_account_history(Date.new(2008,12,1)).should be_nil
  end
end

describe Endpoint,'with some account histories and some transactions' do
  before(:all) do
    ModelSpecHelper.setup_database
  end
  before(:each) do
    Endpoint.delete_all
    ModelSpecHelper.create_nested_endpoints [
      :bank,:wallet,:food,:house_rent
    ]
    ModelSpecHelper.import_endpoints self
    Transaction.delete_all
    ModelSpecHelper.create_transactions [
      [9,30,@bank,@house_rent,50000],
      [10,3,@bank,@wallet,5000]
    ]
    AccountHistory.delete_all
    ModelSpecHelper.create_account_history [
      [10,1,@bank,10000],
      [10,2,@wallet,2000],
      [10,3,@bank,20000],
      [10,4,@wallet,4000]
    ]
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
    @bank.amount_at(date).should be == 0
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

describe Endpoint,'#balance with some transactions' do
  before(:all) do
    ModelSpecHelper.setup_database
  end
  before(:each) do
    Endpoint.delete_all
    ModelSpecHelper.create_nested_endpoints [
      :stash,
      [:bank,:stash],
      [:wallet,:stash],
      :expense,
      [:food,:expense],
      [:house_rent,:expense],
      :income,
      [:salary,:income]
    ]
    ModelSpecHelper.import_endpoints self
    Transaction.delete_all
    ModelSpecHelper.create_transactions [
      [9,29,@bank,@wallet,10000],
      [9,30,@wallet,@food,2000],
      [10,1,@wallet,@bank,20000],
      [10,2,@salary,@bank,100000],
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
  def assert_balance(endpoint,from,to,expected_balance)
    endpoint.balance(from..to,endpoint).should be == expected_balance
  end

  it 'should -10000 balance at bank and +10000 at wallet at 9-29' do
    a=Date.new(2008,9,29)
    b=Date.new(2008,9,29)
    assert_balance(@bank       , a , b , -10000 )
    assert_balance(@wallet     , a , b , +10000 )
    assert_balance(@food       , a , b , 0      )
    assert_balance(@house_rent , a , b , 0      )
    assert_balance(@salary     , a , b , 0      )
  end
  it 'should right balance at 9-29 to 9-30' do
    a=Date.new(2008,9,29)
    b=Date.new(2008,9,30)
    assert_balance(@bank       , a , b , -10000 )
    assert_balance(@wallet     , a , b , +8000  )
    assert_balance(@food       , a , b , +2000  )
    assert_balance(@house_rent , a , b , 0      )
    assert_balance(@salary     , a , b , 0      )
  end
  it 'should right balance at 9-29 to 10-01' do
    a=Date.new(2008,9,29)
    b=Date.new(2008,10,1)
    assert_balance(@bank       , a , b , +10000 )
    assert_balance(@wallet     , a , b , -12000 )
    assert_balance(@food       , a , b , +2000  )
    assert_balance(@house_rent , a , b , 0      )
    assert_balance(@salary     , a , b , 0      )
  end
  it 'should right balance at 9-29 to 10-02' do
    a=Date.new(2008,9,29)
    b=Date.new(2008,10,2)
    assert_balance(@bank       , a , b , +45000  )
    assert_balance(@wallet     , a , b , +3000   )
    assert_balance(@food       , a , b , +2000   )
    assert_balance(@house_rent , a , b , +50000  )
    assert_balance(@salary     , a , b , -100000 )
  end
  it 'should right balance at 9-29 to 10-03, its same as 9-29 to 10-02' do
    a=Date.new(2008,9,29)
    b=Date.new(2008,10,3)
    assert_balance(@bank       , a , b , +45000  )
    assert_balance(@wallet     , a , b , +3000   )
    assert_balance(@food       , a , b , +2000   )
    assert_balance(@house_rent , a , b , +50000  )
    assert_balance(@salary     , a , b , -100000 )
  end
  it 'should right balance at 9-29 to 10-04' do
    a=Date.new(2008,9,29)
    b=Date.new(2008,10,4)
    assert_balance(@bank       , a , b , +45000  )
    assert_balance(@wallet     , a , b , +500    )
    assert_balance(@food       , a , b , +4500   )
    assert_balance(@house_rent , a , b , +50000  )
    assert_balance(@salary     , a , b , -100000 )
  end
end

describe Endpoint,'with nested' do
  before(:all) do
    ModelSpecHelper.setup_database
  end
  before(:each) do
    Endpoint.delete_all
    ModelSpecHelper.create_nested_endpoints [
      [:stash,nil],
      [:bank,:stash],
      [:wallet,:stash],
      [:expense,nil],
      [:utility_bill,:expense],
      [:electricity_bill,:utility_bill],
      [:food,:expense]
    ]
    ModelSpecHelper.import_endpoints self
    Transaction.delete_all
    ModelSpecHelper.create_transactions [
      [9,30,@bank,@electricity_bill,50000],
      [10,3,@bank,@wallet,5000]
    ]
  end
  it 'should be returns collect parent' do
    @bank.parent.should be == @stash
    @electricity_bill.parent.should be == @utility_bill
    @electricity_bill.parent.parent.should be == @expense
  end
  it 'should be returns collect children' do
    @bank.children.length.should be == 0
    @utility_bill.children.length.should be == 1
    @utility_bill.children[0].should be == @electricity_bill
  end
  it 'should be returns all descendants' do
    @electricity_bill.descendants.length.should be == 0
    @expense.descendants.length.should be == 3
    @expense.descendants.include?(@food).should be_true
    @expense.descendants.include?(@utility_bill).should be_true
    @expense.descendants.include?(@electricity_bill).should be_true
  end
  it '#descendants should not currupt hierarchy' do
    @electricity_bill.parent.id.should be @utility_bill.id
    @expense.descendants.inject(@expense.balance(nil,false)){|a,d|
      a+d.balance(nil,false)
    }
    @electricity_bill.reload
    @utility_bill.reload
    @electricity_bill.parent.id.should be @utility_bill.id
  end
end

describe Endpoint,'#balance with nested endpoint' do
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
  def d(y,m,d); Date.new(y,m,d); end
  it 'should returns expense endpoint\'s balance between 10-10 to 10-15(sub endpoint is excluded)' do
    @expense.balance(d(2008,10,10)..d(2008,10,15),false).should be == 1000
  end
  it 'should returns expense endpoint\'s balance between 10-10 to 10-15(sub endpoint is included)' do
    @expense.balance(d(2008,10,10)..d(2008,10,15),true).should be == 2000
    @expense.balance(d(2008,10,10)..d(2008,10,15)).should be == 2000
    @stash.balance(d(2008,10,10)..d(2008,10,15)).should be == 98000
  end
  it 'should returns expense endpoint\'s balance between 10-10 to 10-15(sub endpoint is included)' do
    @expense.balance(d(2008,10,10)..d(2008,10,15),true).should be == 2000
  end
  it 'should returns balance of specified day/month/year' do
    @wallet.balance_at(2009).should be == +8000
    @wallet.balance_at(2008,11).should be == +39000
    @wallet.balance_at(2008,10,10).should be == +9000
    @wallet.balance_at(2009,1,3).should be == -2000
    @wallet.balance_at().should == 74700
  end
end

describe Endpoint,'#newest_account_history with some histories' do
  before(:all) do
    ModelSpecHelper.setup_database
  end
  before(:each) do
    Endpoint.delete_all
    ModelSpecHelper.create_nested_endpoints [
      :bank, :wallet
    ]
    ModelSpecHelper.import_endpoints self
    AccountHistory.delete_all
    ModelSpecHelper.create_account_history [
      [10,1,@bank,1000],
      [10,2,@bank,2000],
      [10,3,@bank,3000],
      [10,4,@bank,1500]
    ]
  end
  it 'should have endpoint column as Endpoint' do
    @bank.newest_account_history(Date.new(2008,10,1)).endpoint.should be == @bank
  end
  it 'should error when newest_account_history called with non Date object as 2nd argument' do
    lambda{@bank.newest_account_history(nil)}.should raise_error(ArgumentError)
    lambda{@bank.newest_account_history('2008-10-1')}.should raise_error(ArgumentError)
  end
  it 'should no histories before 2008-10-01' do
    @bank.newest_account_history(Date.new(2008,9,30)).should be_nil
  end
  it 'should exists the newest history upto 2008-10-03 and its date is 2008-10-03' do
    @bank.newest_account_history(Date.new(2008,10,3)).should_not be_nil
    @bank.newest_account_history(Date.new(2008,10,3)).date.should be == Date.new(2008,10,3)
  end
  it 'should exists the newest history upto 2008-10-31 and its date is 2008-10-04' do
    @bank.newest_account_history(Date.new(2008,10,31)).should_not be_nil
    @bank.newest_account_history(Date.new(2008,10,31)).date.should be == Date.new(2008,10,4)
  end
end

describe Endpoint,'with transactions' do
  before(:all) do
    ModelSpecHelper.setup_database
  end
  before(:each) do
    Endpoint.delete_all
    ModelSpecHelper.create_nested_endpoints [
      :stash,
      [:bank,:stash],
      [:wallet,:stash],
      :expense,
      :income
    ]
    ModelSpecHelper.import_endpoints self
    Transaction.delete_all
    ModelSpecHelper.create_transactions [
      [9,1,@income,@bank,1000],
      [9,2,@bank,@wallet,500],
      [9,3,@wallet,@expense,2500],
      [9,4,@bank,@expense,1500],
      [9,5,@income,@expense,2000]
    ]
  end

  it '#transactions should return relative transactions' do
    @bank.transactions.length.should == 3
    @wallet.transactions.length.should == 2
    @income.transactions.length.should == 2
    @stash.transactions.length.should == 4 #including sub endpoint by default
  end

  it '#transactions should return relative transactions in specified date range' do
    @bank.transactions(Date.new(2008,9,1)...Date.new(2008,9,1)).to_a.length.should == 0
    @bank.transactions(Date.new(2008,9,1)..Date.new(2008,9,1)).to_a.length.should == 1
    @bank.transactions(Date.new(2008,9,1)...Date.new(2008,9,2)).to_a.length.should == 1
    @bank.transactions(Date.new(2008,9,1)..Date.new(2008,9,2)).to_a.length.should == 2
    @bank.transactions(Date.new(2008,9,1)..Date.new(2008,9,3)).to_a.length.should == 2
    @bank.transactions(Date.new(2008,9,1)..Date.new(2008,9,4)).to_a.length.should == 3
    @bank.transactions(Date.new(2008,9,1)..Date.new(2008,9,5)).to_a.length.should == 3
  end

  it '#incomeshould return sum of incomes' do
    @bank.income(nil).should == 1000
    @income.income(nil).should == 0
    @stash.income(nil).should == 1000
  end
  it '#expense should return sub of expenses' do
    @bank.expense(nil).should == 2000
    @income.expense(nil).should == 3000
    @stash.expense(nil).should == 4000
  end
  it '#income should return income at specified date/month/year' do
    @bank.income(Date.new(2008,9,1)).should == 1000
    @bank.income(Date.new(2008,9,2)).should == 0
    @bank.income(Date.new(2008,9,1)..Date.new(2008,9,30)).should == 1000
    @bank.income(Date.new(2008,1,1)..Date.new(2008,12,31)).should == 1000
  end
  it '#expense should return expense at specified date/month/year' do
    @bank.expense(Date.new(2008,9,1)).should == 0
    @bank.expense(Date.new(2008,9,2)).should == 500
    @bank.expense(Date.new(2008,9,1)..Date.new(2008,9,30)).should == 2000
    @bank.expense(Date.new(2008,1,1)..Date.new(2008,12,31)).should == 2000
  end
end
