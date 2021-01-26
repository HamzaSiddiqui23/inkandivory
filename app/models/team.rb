class Team < ApplicationRecord
	has_many :users

	def display_name
    	self.team_name
  	end
end
