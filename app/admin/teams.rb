ActiveAdmin.register Team do
	permit_params :team_name, :manager_id
	
	actions :all, except: :destroy

	form do |f|
		f.inputs do
			f.input :team_name
			f.input :manager_id, as: :select, collection: User.where(team_id: object.id)
			actions
		end
	end

	show :title => :team_name do
		attributes_table do
			row :team_name
			row :manager do |m|
				m.manager_id.nil? ? nil : User.find(m.manager_id).full_name
			end
		end
		panel 'Team Members', only: :show do
			table_for team.users do
				column :full_name
				column :role
			end
		end
		active_admin_comments
	end
end