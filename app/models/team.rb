class Team < ApplicationRecord
	has_many :users
	has_many :client_tasks

	def display_name
    	self.team_name
  	end

	def self.all_names
		teams = []
		Team.all.each do |t|
			teams.push(t.team_name)
		end
		return teams
	end

end
