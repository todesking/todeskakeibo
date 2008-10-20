require 'spec/model_spec_helper.rb'

describe AccountHistory,'with no history' do
  before(:all) do
    ModelSpecHelper.setup_database
    @wallet=Endpoint.new(:name=>'wallet')
    @wallet.save
    @bank=Endpoint.new(:name=>'bank')
    @bank.save
  end
  before(:each) do
    AccountHistory.delete_all
  end
  it 'should no amount in any account and any time' do
    AccountHistory.newest_history(@wallet,Date.new(2007,1,1)).should be_nil
    AccountHistory.newest_history(@bank,Date.new(2008,12,1)).should be_nil
  end
end

describe AccountHistory,'with some histories' do
  before(:all) do
    ModelSpecHelper.setup_database
  end
  before(:each) do
    Endpoint.delete_all
    [
      { :name => 'bank' },
      { :name => 'wallet'},
    ].each{|ep|
      endpoint=Endpoint.new(ep)
      endpoint.save
      instance_variable_set('@'+ep[:name],endpoint)
    }
    AccountHistory.delete_all
    ModelSpecHelper.create_account_history [
      [10,1,@bank,1000],
      [10,2,@bank,2000],
      [10,3,@bank,3000],
      [10,4,@bank,1500]
    ]
  end
  it 'should error when newest_history called with non Endpoint object as 1st argument' do
    lambda{AccountHistory.newest_history('bank',Date.new(2008,10,3))}.should raise_error(ArgumentError)
    lambda{AccountHistory.newest_history(nil,Date.new(2008,10,3))}.should raise_error(ArgumentError)
  end
  it 'should error when newest_history called with non Date object as 2nd argument' do
    lambda{AccountHistory.newest_history(@bank,nil)}.should raise_error(ArgumentError)
    lambda{AccountHistory.newest_history(@bank,'2008-10-1')}.should raise_error(ArgumentError)
  end
  it 'should exists the history at 2008-10-02' do
    AccountHistory.find_by_date('2008-10-02').should_not be_nil
  end
  it 'should no histories before 2008-10-01' do
    AccountHistory.newest_history(@bank,Date.new(2008,9,30)).should be_nil
  end
  it 'should exists the newest history upto 2008-10-03 and its date is 2008-10-03' do
    AccountHistory.newest_history(@bank,Date.new(2008,10,3)).should_not be_nil
    AccountHistory.newest_history(@bank,Date.new(2008,10,3)).date.should be == Date.new(2008,10,3)
  end
  it 'should exists the newest history upto 2008-10-31 and its date is 2008-10-04' do
    AccountHistory.newest_history(@bank,Date.new(2008,10,31)).should_not be_nil
    AccountHistory.newest_history(@bank,Date.new(2008,10,31)).date.should be == Date.new(2008,10,4)
  end
end
