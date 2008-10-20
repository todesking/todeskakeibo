require 'spec/model_spec_helper.rb'

describe AccountHistory,'with no history' do
  before(:all) do
    ModelSpecHelper.setup_database
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
    [
      { :date => '2008-10-01', :name => @bank, :amount => 1000},
      { :date => '2008-10-02', :name => @bank, :amount => 2000},
      { :date => '2008-10-03', :name => @bank, :amount => 3000},
      { :date => '2008-10-04', :name => @bank, :amount => 1500}
    ].each{|t|
      AccountHistory.new(t).save
    }
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
