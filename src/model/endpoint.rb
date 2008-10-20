class Endpoint < ActiveRecord::Base
  belongs_to :parent,:class_name=>'Endpoint',:foreign_key=>:parent
  def amount_at(at)
    history=AccountHistory.newest_history(self,at)
    if history.nil?
      return 0 + Transaction.balance_between(self,nil,at)
    else
      return history.amount + Transaction.balance_between(self,history.date,at)
    end
  end
end
