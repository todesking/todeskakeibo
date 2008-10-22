require File.dirname(__FILE__)+'/'+'../src/controller.rb'
require File.dirname(__FILE__)+'/'+'model/spec_helper.rb'

describe Controller,'commands' do
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

  it 'should define base_date' do
    @c.execute('base_date 20071011')
    @c.execute('transaction 10 b wallet 10000')
    tr=Transaction.find(:first)
    tr.date.should be == Date.new(2007,10,10)
  end

  it 'should define transaction' do
    @c.execute('transaction 20081001 b wallet 10000')
    tr=Transaction.find(:first)
    tr.date.should be == Date.new(2008,10,1)
    tr.src.should be == @bank
    tr.dest.should be == @wallet
    tr.amount.should be == 10000
  end

  it 'should define account' do
    @c.execute('account 20081010 b 200000')
    ah=AccountHistory.find(:first)
    ah.endpoint.should be == @bank
    ah.date.should be == Date.new(2008,10,10)
    ah.amount.should be == 200000
  end

  it 'should define endpoint' do
    @c.execute('endpoint credit stash')
    cr=Endpoint.find_by_name('credit')
    cr.should_not be_nil
    cr.parent.should be == @stash
  end

  it 'should define endpoint with no parent' do
    @c.execute('endpoint other')
    cr=Endpoint.find_by_name('other')
    cr.parent.should be_nil
  end
end
