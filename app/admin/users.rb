ActiveAdmin.register User do

	permit_params :first_name, :joining_date, :last_name, :user_name, :resume_file, :resume, :password, :password_confirmation, :team_id, :manager_id, :role, :email,:phone, :identification, :birthday, :bank_name, :account_number, :mailing_address
	actions :all, except: :destroy
	filter :first_name
	filter :last_name
	filter :manager_id, as: :select, collection: User.all
	filter :team 

  scope :active

	index do
    actions
		column :first_name
		column :last_name
		column :team
    column :manager do |m|
      m.manager_id.nil? ? nil : User.find(m.manager_id).full_name
     end
		column :role
		column :email
	end

  form partial: 'form'

   sidebar 'User Information', :only => :show do
    attributes_table do
      row :first_name
      row :last_name
      row :status
      row :manager do |m|
        m.manager_id.nil? ? nil : User.find(m.manager_id).full_name
      end
      row :team
      row :role
      row :email
      row :user_name
    end
  end

  show :title => :full_name do
	   attributes_table 'More Info' do
      row  :resume do |r|
        r.resume.nil? ? nil : link_to('View Resume', r.get_resume, target: :_blank)
      end
        row :mailing_address
	      row :identification
	 	    row :birthday
        row :joining_date
        row :bank_name
        row :account_number
    end
  end
  action_item :reset_password, only: :show, :if => proc { resource.status == "Active" }  do
    link_to "Reset Password", edit_admin_user_path(id: resource.id, reset_password: true)
  end  

end