require File.dirname(__FILE__)+'/'+'../src/controller.rb'
require File.dirname(__FILE__)+'/'+'model/spec_helper.rb'

describe Controller,'commands' do
  before(:each) do
    @c=Controller.new
    ModelSpecHelper.setup_database
  end
  it 'should define transaction' do
    @c.execute('transaction 20081001 bank wallet 10000')
    Transaction.find(:first).src.name.should be == 'bank'
    Transaction.find(:first).amount.should be == 10000
  end
end
