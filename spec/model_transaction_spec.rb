require 'src/model/transaction.rb'
describe Transaction do
  before(:all) do
    ActiveRecord::Base.establish_connection(
      :adapter => 'sqlite3',
      :dbfile => ':memory:'
    )
    con=ActiveRecord::Base.connection
    con.execute <<-'EOS'
    create table transactions (
      id integer not null primary key,
      date datetime not null,
      src string not null,
      dest string not null,
      amount integer not null
    )
    EOS
  end
  before(:each) do
    Transaction.delete_all
  end
  it 'should can store data' do
    Transaction.find(:all).length.should be(0)
    Transaction.new(
      :date => '2008-10-18',
      :src => :bank,
      :dest => :wallet,
      :amount => 1000
    ).save
    Transaction.find(:all).length.should be(1)
    Transaction.find(:first).amount.should be(1000)
  end
end
