require 'spec/model_spec_helper.rb'

describe Transaction do
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
      :amount => 1000
    ).save
    Transaction.find(:all).length.should be == 1
    Transaction.find(:first).amount.should be == 1000
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
