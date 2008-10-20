class Endpoint < ActiveRecord::Base
  def amount_at(at)
    history=AccountHistory.newest_history(self.name,at)
    if history.nil?
      return 0 + Transaction.balance_between(self.name,nil,at)
    else
      return history.amount + Transaction.balance_between(self.name,history.date,at)
    end
  end
end
