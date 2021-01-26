ActiveAdmin.register Client do

	permit_params :name, :client_representative, :frequency_of_payment, :minimum_due_amount, :source, :phone, :email, :payment_method

	actions :all, except: :destroy

	filter :name
	filter :status, as: :select, collection: AppConstant::CLIENT_STATUS, include_blank: true
	filter :client_representative, as: :select, collection: User.where(role: "Management")

	index do
		actions
		column :name
		column :client_representative do |m|
        	m.client_representative.nil? ? nil : User.find(m.client_representative).full_name
      	end
      	column :status
	end

	form do |f|
		f.inputs do
			f.input :name
			f.input :phone
			f.input :email
			f.input :source
			f.input :client_representative, as: :select, collection: User.where(role: "Management")
			f.input :payment_method, as: :select, collection: AppConstant::PAYMENT_METHOD, include_blank: false
			f.input :frequency_of_payment, as: :select, collection: AppConstant::PAYMENT_FREQUENCY, include_blank: false
			f.input :minimum_due_amount
			if !f.object.new_record?
				f.input :status, as: :select, collection: AppConstant::CLIENT_STATUS, include_blank: false
			end
			actions
		end
	end

	sidebar 'Client Information', :only => :show do
    attributes_table do
      row :name
      row :phone
      row :email
      row :client_representative do |m|
        m.client_representative.nil? ? nil : User.find(m.client_representative).full_name
      end
      row :source
      row :payment_method
      row :frequency_of_payment
      row :minimum_due_amount
      row :created_at
    end
  end

  show do
  	active_admin_comments
  end
end