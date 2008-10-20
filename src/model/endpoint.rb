class Endpoint < ActiveRecord::Base
  def amount_at(at)
    amount=0
    history=AccountHistory.newest_history(self.name,at)
    amount=history.amount unless history.nil?
    amount+=Transaction.balance_between(self.name,history.nil? ? nil : history.date,at)
    amount
  end
end
