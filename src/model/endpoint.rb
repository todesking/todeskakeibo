class Endpoint < ActiveRecord::Base
  def amount_at(at)
    history=AccountHistory.newest_history(self.name,at)
    return 0 if history.nil?
    history.amount
  end
end
