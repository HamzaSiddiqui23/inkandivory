ActiveAdmin.register User do

	permit_params :first_name, :last_name, :user_name, :password, :password_confirmation, :team, :manager_id, :role, :email,:phone, :identification, :birthday, :bank_name, :account_number, :mailing_address
	actions :all, except: :destroy
	filter :first_name
	filter :last_name
	filter :manager_id, as: :select, collection: User.all
	filter :team 

	index do
    actions
		column :first_name
		column :last_name
		column :team
		column :manager_id
		column :role
		column :email
	end

  form do |f|
    f.inputs do
      f.input :first_name
      f.input :last_name
      f.input :user_name
      f.input :password
      f.input :password_confirmation
		 f.input  :team
		 f.input  :manager_id, as: :select, collection: User.all
		 f.input  :role
		 f.input  :email
		  f.input :phone
		  f.input :identification
		  f.input :birthday
		  f.input :bank_name
		  f.input :account_number
		  f.input :mailing_address

    end
    f.actions
  end

   sidebar 'User', :only => :show do
    attributes_table do
      row :first_name
      row :last_name
      row :manager do |m|
        m.manager_id.nil? ? nil : Employee.find(m.manager_id).full_name
      end
      row :role
      row :email
      row :mailing_address
      row :status
    end
  end

  show :title => :full_name do
	 attributes_table do
	 	row :identification
	 	row :birthday
      	row :joining_date
     	row :bank_name
      	row :account_number
      end
  end
end