class CreateIncomes < ActiveRecord::Migration
  def self.up
    create_table :incomes do |t|
      t.integer :money
      t.integer :category
      t.integer :description
      t.date :date

      t.timestamps
    end
  end

  def self.down
    drop_table :incomes
  end
end
