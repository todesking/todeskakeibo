require 'src/model/account_history.rb'
require 'src/model/helper.rb'

describe AccountHistory,'with empty' do
  before(:all) do
    ActiveRecord::Base.establish_connection(
      :adapter => 'sqlite3',
      :dbfile => ':memory:'
    )
    ModelHelper.create_tables
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
