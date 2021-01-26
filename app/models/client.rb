class Client < ApplicationRecord 
  	
  	validates :name, presence: true
  	validates :client_representative, presence: true

  	validate :check_minimum_dues

  	before_create :set_status

  	def set_status
  		self.status = "Active"
  	end

	def display_name
    	self.name
  	end

  	def check_minimum_dues
  		if frequency_of_payment == "Minimum Dues" && minimum_due_amount == nil
  			errors.add(:minimum_due_amount, "Please select minimum due amount")
  		end
  	end
end