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
  it 'should define transaction' do
    id=@c.execute('transaction 20081001 b wallet 10000')
    tr=Transaction.find(:first)
    id.should be == tr.id
    tr.src.name.should be == 'bank'
    tr.amount.should be == 10000
  end
end
