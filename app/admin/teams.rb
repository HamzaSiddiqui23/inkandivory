ActiveAdmin.register Team do
	menu if: proc{ current_user.is_manager? || current_user.is_admin?  }
	permit_params :team_name, :manager_id
	
	actions :all, except: :destroy

	RESTRICTED_ACTIONS = ["edit", "update", "create", "new"]

    controller do
		def action_methods
		  if current_user.is_admin?
			super
		  else
			super - RESTRICTED_ACTIONS
		  end
		end
	  end

	index do 
		column do |v|
			link_to 'View', "teams/#{v.id}"  
		end
		column :team_name
		column :manager do |m|
			m.manager_id.nil? ? nil : User.find(m.manager_id).full_name
		end
	end

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
				column "View" do |v|
					link_to 'View', "../users/#{v.id}"  if current_user.is_admin? || current_user.id == resource.manager_id
				end
				column :full_name
				column :role
			end
		end
		active_admin_comments
	end
end