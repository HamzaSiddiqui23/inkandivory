class AddAmmountLimitToClient < ActiveRecord::Migration[6.1]
  def change
  	change_table :clients do |t|
  		t.integer :minimum_due_amount
  	end
  end
end