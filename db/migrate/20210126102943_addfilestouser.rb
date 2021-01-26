class Addfilestouser < ActiveRecord::Migration[6.1]
  def change
  	change_table :users do |t|
  		t.string :resume
  		t.binary :resume_file
  	end
  end
end