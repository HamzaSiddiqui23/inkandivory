class AddInfoToUsers < ActiveRecord::Migration[6.1]
  def change
  	change_table :users do |t|
  		t.date :joining_date
  		t.string :status
  	end
  end
end
