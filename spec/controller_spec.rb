require File.dirname(__FILE__)+'/'+'../src/controller.rb'
require File.dirname(__FILE__)+'/'+'model/spec_helper.rb'

describe Controller,'#execute' do
  before(:each) do
    ModelSpecHelper.setup_database
    @c=Controller.new
  end
  it 'should ignore empty string' do
    @c.execute('')
  end
  it 'should execute multiple commands' do
    @c.execute(<<-'EOS'.split("\n"))
      endpoint hoge
      endpoint hage hoge

      transaction 20081001 hoge hage 10000
    EOS
    Endpoint.find(:all).length.should be == 2
    Transaction.find(:first).amount.should be == 10000
  end
end

describe Controller,'#type_parser' do
  before(:all) do
    @c=Controller.new
    ModelSpecHelper.setup_database
    ModelSpecHelper.create_nested_endpoints [
      :stash,
      [:wallet,:stash],
      [:bank,:stash]
    ]
    ModelSpecHelper.import_endpoints self
    ModelSpecHelper.create_endpoint_aliases [
      [:w,@wallet]
    ]
    ModelSpecHelper.create_transactions [
      [10,1,@wallet,@bank,10000]
    ]
  end

  it 'should defined and not nil' do
    @c.type_parser.should_not be_nil
  end

  it 'should parse Endpoint by real name' do
    @c.type_parser.parse('wallet',Endpoint).should == @wallet
  end

  it 'should parse Endpoint by alias' do
    @c.type_parser.parse('w',Endpoint).should == @wallet
  end

  it 'should error when parsing Endpoint with unknown name' do
    lambda { @c.type_parser.parse('undef',Endpoint) }.should raise_error(ArgumentError)
  end

  it 'should parse Transaction by id' do
    @c.type_parser.parse('1',Transaction).id.should == 1
  end
end

describe Controller,'command' do
  before(:each) do
    @c=Controller.new
    ModelSpecHelper.setup_database
    ModelSpecHelper.create_nested_endpoints [
      :stash,
      [:bank,:stash],
      [:wallet,:stash],
      :expense,
      [:food,:expense]
    ]
    ModelSpecHelper.import_endpoints self
    ModelSpecHelper.create_endpoint_aliases [
      [:w,@wallet],
      [:b,@bank]
    ]
    ModelSpecHelper.create_transactions [
    ]
  end

  it 'base_date should define base_date' do
    @c.execute('base_date 20071011')
    @c.execute('transaction 10 b wallet 10000')
    tr=Transaction.find(:first)
    tr.date.should be == Date.new(2007,10,10)
  end

  it 'transaction should add transaction record' do
    @c.execute('transaction 20081001 b wallet 10000')
    tr=Transaction.find(:first)
    tr.date.should be == Date.new(2008,10,1)
    tr.src.should be == @bank
    tr.dest.should be == @wallet
    tr.amount.should be == 10000
  end

  it 'transaction should accepts description argument' do
    @c.execute('transaction 20081010 wallet food 105 シュークリーム')
    Transaction.find(:first).amount.should == 105
    Transaction.find(:first).description.should == 'シュークリーム'
  end

  it 'account should add account record' do
    @c.execute('account 20081010 b 200000')
    ah=AccountHistory.find(:first)
    ah.endpoint.should be == @bank
    ah.date.should be == Date.new(2008,10,10)
    ah.amount.should be == 200000
    ah.description.should be_nil
  end

  it 'account should accepts description' do
    @c.execute('account 20081010 b 200000 wtf')
    ah=AccountHistory.find(:first)
    ah.endpoint.should be == @bank
    ah.date.should be == Date.new(2008,10,10)
    ah.amount.should be == 200000
    ah.description.should == 'wtf'
  end

  it 'endpoint should add endpoint' do
    @c.execute('endpoint credit stash')
    cr=Endpoint.find_by_name('credit')
    cr.should_not be_nil
    cr.parent.should be == @stash
  end

  it 'endpoint should accepts description' do
    @c.execute('endpoint credit stash クレジットカード')
    cr=Endpoint.find_by_name('credit')
    cr.should_not be_nil
    cr.parent.should be == @stash
    cr.description.should == 'クレジットカード'
  end

  it 'endpoint should add endpoint with no parent' do
    @c.execute('endpoint other')
    cr=Endpoint.find_by_name('other')
    cr.parent.should be_nil
  end

  it 'endpoint_alias should add endpoint alias' do
    Endpoint.lookup('f').should be_nil
    @c.execute('endpoint_alias f food')
    Endpoint.lookup('f').should be == @food
  end

  it 'delete transaction should delete the transaction' do
    tr=Transaction.new(:date=>Date.new(2008,10,23),:src=>@wallet,:dest=>@food,:amount=>1000)
    tr.save
    tr.id.should == 1
    Transaction.find_by_id(1).should_not be_nil
    @c.execute('delete transaction 1')
    Transaction.find_by_id(1).should be_nil
  end
  it 'delete account_history should delete the account_history' do
    tr=AccountHistory.new(:date=>Date.new(2008,10,23),:endpoint=>@wallet,:amount=>1000)
    tr.save
    tr.id.should == 1
    AccountHistory.find_by_id(1).should_not be_nil
    @c.execute('delete account_history 1')
    AccountHistory.find_by_id(1).should be_nil
  end
  it 'delete endpoint should delete the endpoint' do
    ep=Endpoint.new(:name=>'hage')
    ep.save
    id=ep.id
    id.should_not be_nil
    Endpoint.find_by_id(id).should_not be_nil
    @c.execute('delete endpoint '+id.to_s)
    Endpoint.find_by_id(id).should be_nil
  end
  it 'delete endpoint_alias should delete the endpoint alias' do
    epa=EndpointAlias.new(:name=>'hage',:endpoint=>@wallet)
    epa.save
    id=epa.id
    id.should_not be_nil
    EndpointAlias.find_by_id(id).should_not be_nil
    @c.execute('delete endpoint_alias '+id.to_s)
    EndpointAlias.find_by_id(id).should be_nil
  end
  it 'should set endpoint\'s parent and name' do
    @c.execute('endpoint hage')
    @c.execute('endpoint fuga')
    
    @c.execute('set endpoint hage parent= fuga')
    Endpoint.find_by_name('hage').parent.should == Endpoint.find_by_name('fuga')

    Endpoint.find_by_name('hoge').should be_nil
    @c.execute('set endpoint hage name= hoge')
    Endpoint.find_by_name('hage').should be_nil
    Endpoint.find_by_name('hoge').should_not be_nil
  end
  it 'should set transaction\'s src/dest/amount/date' do
    @c.execute([
               'endpoint super food',
               'endpoint snack food',
               'transaction 20081001 wallet super 500 comment'
    ])
    t=Transaction.find(:first)
    t.src.name.should == 'wallet'
    t.id.should == 1
    @c.execute('set transaction 1 src= bank')
    Transaction.find(:first).src.name.should =='bank'

    #set src endpoint by alias
    t=Transaction.find(:first)
    t.src.name.should == 'bank'
    @c.execute('set transaction 1 src= w')
    Transaction.find(:first).src.name.should =='wallet'

    t=Transaction.find(:first)
    t.dest.name.should == 'super'
    @c.execute('set transaction 1 dest= super')
    Transaction.find(:first).dest.name.should =='super'

    t=Transaction.find(:first)
    t.amount.should == 500
    @c.execute('set transaction 1 amount= 1000')
    Transaction.find(:first).amount.should == 1000

    t=Transaction.find(:first)
    t.date.should == Date.new(2008,10,1)
    @c.execute('set transaction 1 date= 20080911')
    Transaction.find(:first).date.should == Date.new(2008,9,11)
  end
end
