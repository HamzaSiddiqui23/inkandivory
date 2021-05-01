ActiveAdmin.register User do
  menu parent: 'Users', if: proc{ current_user.is_admin?  }
	permit_params :first_name, :joining_date, :slack_id, :last_name, :user_name, :resume_file, :resume, :password, :password_confirmation, :team_id, :manager_id, :role, :email,:phone, :identification, :birthday, :bank_name, :account_number, :mailing_address
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
      row :status do  |s|
        status_tag s.status
      end
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
    panel 'Tasks', only: :show do
      table_for ClientTask.where(writer_id: user.id) do
      column "View Task" do |v|
        link_to 'View', "../client_tasks/#{v.id}"
      end
      column :task_title
      column :status do  |s|
        status_tag s.status
      end
      end
    end
    panel 'Invoices', only: :show do
      table_for resource.internal_invoices do
      column "View Invoice" do |v|
        link_to 'View', "../internal_invoices/#{v.id}"
      end
      column :invoice_created_date
      column :status do  |s|
        status_tag s.status
      end
      column :writer_total  unless user.role != "Individual Contributor"
      column :manager_total unless user.role == "Individual Contributor"
      end
    end
  end
  action_item :reset_password, only: :show, :if => proc { resource.status == "Active" }  do
    link_to "Reset Password", edit_admin_user_path(id: resource.id, reset_password: true)
  end  

end