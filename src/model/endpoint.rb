class Endpoint < ActiveRecord::Base
  def amount_at(at)
    amount=0
    history=AccountHistory.newest_history(self.name,at)
    amount=history.amount unless history.nil?
    if history.nil?
      oldest_transaction=Transaction.find(:first,:conditions=>['(src = ? or dest = ?) and date <= ?',self.name,self.name,at],:order=>'date')
      amount+=Transaction.balance_between(self.name,oldest_transaction.date,at) unless oldest_transaction.nil?
    else
      start_date=history.date
      amount+=Transaction.balance_between(self.name,start_date,at)
    end
    amount
  end
end
