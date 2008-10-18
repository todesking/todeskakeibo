require 'spec/model_spec_helper.rb'

describe AccountHistory,'with empty' do
  before(:all) do
    ModelSpecHelper.setup_database
  end
  before(:each) do
    AccountHistory.delete_all
    Transaction.delete_all
  end
  it 'should no amount in any account' do
    AccountHistory.current_amount(:bank).should be(0)
    AccountHistory.current_amount(:wallet).should be(0)
  end
end

describe AccountHistory,'with some histories' do

end
