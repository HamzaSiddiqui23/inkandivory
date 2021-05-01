class AddTeamToClientTask < ActiveRecord::Migration[6.1]
  def change
    change_table :client_tasks do |t|
      t.integer :team_id, :refrences => :teams
    end
  end
end
