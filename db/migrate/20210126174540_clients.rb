class Clients < ActiveRecord::Migration[6.1]
  def change
  	create_table :clients do |t|
  		t.string :name
  		t.string :phone
  		t.string :email
  		t.string :source
  		t.string :status
  		t.string :client_representative
  		t.string :payment_method
  		t.string :frequency_of_payment
  		t.timestamps
  	end
  end
end