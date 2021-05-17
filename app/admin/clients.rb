ActiveAdmin.register Client do
	menu if: proc{ current_user.is_manager? || current_user.is_admin?  }
	permit_params :name, :client_representative, :frequency_of_payment, :minimum_due_amount, :source, :phone, :email, :payment_method, :status

	actions :all, except: :destroy

	filter :name
	filter :status, as: :select, collection: AppConstant::CLIENT_STATUS, include_blank: true
	filter :client_representative, as: :select, collection: User.where(role: "Management").or(User.where(role: "Admin"))
	
	scope :all
	scope("My Clients", default: true,if: proc{ current_user.is_manager?  }) { |scope| scope.where(client_representative: current_user.id)}

	index do
		column do |v|
			link_to 'View', "clients/#{v.id}"  
		end
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
			f.input :client_representative, as: :select, collection: User.where(role: "Management").or(User.where(role: "Admin"))
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

#   member_action :create_invoice do

# 		tasks = ClientTask.where(client_id: resource.id, status: 'Approved').and(ClientTask.where.not(client_payment_status: "Paid"))
# 		inv = ClientInvoice.create!(invoice_created_date: Date.today, user_id: current_user.id, status: 'Due', client_id: resource.id, total_amount: tasks.map(&:client_payment_due).inject(0, &:+))
# 		for task in tasks do
# 			ClientInvoiceTask.create!(client_invoice_id: inv.id, client_task_id: task.id)
# 		end
# 	  		flash[:error] = 'Invoice Has Been Created!'
# 		redirect_back fallback_location: root_path
#  	end

#   	action_item :make_invoice, :only => :show do
# 		link_to 'Create Invoice', create_invoice_admin_client_path(resource.id), :id => 'create_invoice_button'
# 	end

  show do
  	  		attributes_table do
  	  			row :total_dues do |t|
  	  				ClientTask.where(client_id: t.id, status: 'Approved').and(ClientTask.where.not(client_payment_status: "Paid")).map(&:client_payment_due).inject(0, &:+)
  	  			end
  	  			row :paid_to_date do |t|
  	  				ClientTask.where(client_id: t.id, status: 'Approved').and(ClientTask.where(client_payment_status: "Paid")).map(&:client_payment_due).inject(0, &:+)
  	  			end
      	end
  	panel 'Tasks', only: :show do
        	table_for resource.client_tasks do
        	column "View Task" do |v|
        		link_to 'View', "../client_tasks/#{v.id}"
        	end
        	column :task_title
        	column :status do  |s|
				status_tag s.status
			end
        	column :delivered_date
        	column :due_date_time
        	column :writer
        	column :client_payment_due
        	column :client_payment_status
        	end
      	end
		  panel 'Invoices', only: :show do
        	table_for resource.client_invoices do
        	column "View Invoice" do |v|
        		link_to 'View', "../client_invoices/#{v.id}"
        	end
        	column :invoice_created_date
        	column :status
        	column :total_amount
        	column :user
        	end
      	end
  	active_admin_comments
  end
end