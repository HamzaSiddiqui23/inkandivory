class Teams < ActiveRecord::Migration[6.1]
  def change
  	create_table :teams do |t|
  		t.string :team_name
  		t.integer :manager_id, 	:refrences => :users
  	end
  end
end
