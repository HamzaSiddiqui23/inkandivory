ActiveAdmin.register ClientTask do

	scope :in_progress, if: proc{ current_user.is_admin?  }
	scope :all, if: proc{ current_user.is_admin?  }
	scope :invoice_client, if: proc{  current_user.is_admin?  }
	scope :invoice_manager, if: proc{ current_user.is_admin?  }
	scope :invoice_writer, if: proc{  current_user.is_admin?  }
	scope("Active Team Tasks", if: proc{ current_user.is_manager?  }) { |scope| scope.where(team_id: current_user.team.id).and(scope.where.not(status: ['Approved', 'Rejected', 'Rejected With Pay']))}
	scope("All Team Tasks", if: proc{ current_user.is_manager?  }) { |scope| scope.where(team_id: current_user.team.id)}
	scope("Invoiceable Tasks", if: proc{ current_user.is_manager?  }) { |scope| scope.where(client_payment_status: 'Due', status: "Approved", team_id: current_user.team.id)}
	scope("My Active Tasks", default: true, if: proc{ current_user.is_writer?  }) { |scope| scope.where(writer_id: current_user.id).and(scope.where.not(status: ['Approved', 'Rejected', 'Rejected With Pay'])) }
	scope("My Finished Tasks", if: proc{ current_user.is_writer?  }) { |scope| scope.where(writer_id: current_user.id).and(scope.where(status: ['Approved', 'Rejected', 'Rejected With Pay'])) }
	scope("All My Tasks", if: proc{ current_user.is_writer?  }) { |scope| scope.where(writer_id: current_user.id)}

	permit_params :user_id, :status, :client_id, :task_title, :required_word_count, :pay_rate, :writer_id, :due_date_time, :details, :delivered_date, :submitted_word_count, :submission_file, :instructions_file, :status, :client_payment_status, :writer_payment_status,  :manager_payment_status
	actions :all
	form partial: 'form'
	config.batch_actions = true

	config.action_items.delete_if { |item|
			item.name == :new || item.name == :edit || item.name == :destroy
	}

	action_item :edit,  only: [ :show ] , if: proc { current_user.is_admin? || current_user.is_manager? } do
		link_to "Edit Task", edit_resource_path(resource)
	end

	action_item :new,  only: [ :index ] , if: proc { current_user.is_admin? || current_user.is_manager? } do
		link_to "New Task", new_resource_path
	end

	batch_action :create_client_invoice_with_required_wc, if: proc{ current_user.is_manager? || current_user.is_admin?  } do |ids|
			tasks = ClientTask.where(id: ids)
			tasks.each do |task|
				task.client_payment_due = task.required_word_count * task.pay_rate
				task.payment_type = "Required Word Count"
				task.save!
			end
			inv = ClientInvoice.create!(invoice_created_date: Date.today,payment_type: "Required Word Count", advance: tasks.map(&:advance).inject(0, &:+), user_id: current_user.id, status: 'Due', client_id: tasks.first.client_id, total_amount: tasks.map(&:client_payment_due).inject(0, &:+))
			for task in tasks do
				ClientInvoiceTask.create!(client_invoice_id: inv.id, client_task_id: task.id)
			end
			redirect_to collection_path, notice: "Invoice Created"
	  end

	batch_action :create_client_invoice_with_submitted_wc, if: proc{ current_user.is_manager? || current_user.is_admin?  } do |ids|
		tasks = ClientTask.where(id: ids)
		inv = ClientInvoice.create!(invoice_created_date: Date.today,payment_type: "Submitted Word Count", advance: tasks.map(&:advance).inject(0, &:+), user_id: current_user.id, status: 'Due', client_id: tasks.first.client_id, total_amount: tasks.map(&:client_payment_due).inject(0, &:+))
		for task in tasks do
			ClientInvoiceTask.create!(client_invoice_id: inv.id, client_task_id: task.id)
		end
		redirect_to collection_path, notice: "Invoice Created"
  	end

	  batch_action :create_writer_invoice, if: proc{ current_user.is_admin?  } do |ids|
		tasks = ClientTask.where(id: ids)
		inv = InternalInvoice.create!(invoice_created_date: Date.today, user_id: tasks.first.writer.id, status: 'Due', writer_total: tasks.map(&:writer_payment_due).inject(0, &:+))
		for task in tasks do
			InternalInvoiceTask.create!(internal_invoice_id: inv.id, client_task_id: task.id)
		end
		redirect_to collection_path, notice: "Invoice Created"
	  end

	  batch_action :create_manager_invoice, if: proc{ current_user.is_admin?  } do |ids|
		tasks = ClientTask.where(id: ids)
		inv = InternalInvoice.create!(invoice_created_date: Date.today, user_id: tasks.first.user_id, status: 'Due',writer_total: tasks.map(&:writer_payment_due).inject(0, &:+), client_total: tasks.map(&:client_payment_due).inject(0, &:+) , manager_total: tasks.map(&:manager_payment_due).inject(0, &:+))
		for task in tasks do
			InternalInvoiceTask.create!(internal_invoice_id: inv.id, client_task_id: task.id)
		end
		redirect_to collection_path, notice: "Invoice Created"
	  end
	
  	member_action :accepting_task do
  	  if resource.update!(status: 'In Progress', task_accepted_date_stamp: DateTime.now)
  	    flash[:error] = 'Task now In Progress!'
  	  else
  	    flash[:error] = 'Something went wrong, Please try later!'
  	  end
  	  redirect_back fallback_location: root_path
	 end
	 	
	 member_action :archiving_task do
  	  if resource.update!(status: 'Archived')
  	    flash[:error] = 'Task Archived!'
  	  else
  	    flash[:error] = 'Something went wrong, Please try later!'
  	  end
  	  redirect_back fallback_location: root_path
	 end
	
	action_item :accept_task, :only => :show do
	  	if resource.status == "Pending" && current_user == resource.writer
	  		link_to 'Start Task', accepting_task_admin_client_task_path(resource.id), :id => 'accept_task_button'
		end
	end

	action_item :archive_task, :only => :show do
		if resource.status != "Complete" || resource.status!="Rejected" || resource.status!="Rejected With Pay" || resource.status!="Archived" && current_user.role != 'Individual Contributor'
			link_to 'Archive Task', archiving_task_admin_client_task_path(resource.id), :id => 'archive_task_button'
	  end
  	end

	
    member_action :move_to_revision do 
        if resource.update!(status: "In Revision", task_revision_date_stamp: DateTime.now, revision_due_date: params[:due_date])
            redirect_back fallback_location: root_path, notice: "Task Moved to Revision!" 
        else
            redirect_back fallback_location: root_path, notice: "Error!" 
        end
    end


	member_action :status_update do
		if params[:status] == "Pending Client Approval"
			resource.update!(status: params[:status], delivered_date: DateTime.now)
		else
		 	if params[:status] == "Rejected"
				resource.update!(status: params[:status], client_payment_status: 'Void', writer_payment_status: 'Void', manager_payment_status: 'Void', approved_rejected_date_stamp: DateTime.now)
			else
				resource.update!(status: params[:status], approved_rejected_date_stamp: DateTime.now)
			end
		end
  	    flash[:error] = 'Task Updated!'
  	  redirect_back fallback_location: root_path
	 end

	action_item :in_revision, :only => :show do
	  	if (resource.status == "Pending Manager Approval" || resource.status == "Pending Client Approval") && current_user.role != 'Individual Contributor'
	  		link_to 'Move to Revision', move_to_revision_admin_client_task_path, :id => 'in_revision_button'
		end
	end

	action_item :client_approval, :only => :show do
	  	if (resource.status == "Pending Manager Approval") && current_user.role != 'Individual Contributor'
	  		link_to 'Move to Pending Client Approval', status_update_admin_client_task_path(resource.id, status: 'Pending Client Approval'), :id => 'accept_task_button'
		end
	end

	action_item :approved, :only => :show do
	  	if (resource.status == "Pending Client Approval") && current_user.role != 'Individual Contributor'
	  		link_to 'Approved', status_update_admin_client_task_path(resource.id, status: 'Approved'), :id => 'accept_task_button'
		end
	end

	action_item :rejected, :only => :show do
	  	if (resource.status == "Pending Client Approval") && current_user.role != 'Individual Contributor'
	  		link_to 'Rejected', status_update_admin_client_task_path(resource.id, status: 'Rejected'), :id => 'accept_task_button'
		end
	end

	action_item :add_advance, :only => :show do
		if current_user.role != 'Individual Contributor' && resource.status!="Archived"
			link_to 'Add Advance', add_advance_admin_client_task_path(resource.id, status: 'Rejected'), :id => 'advance_button'
	  	end
  	end

	member_action :add_advance do 
    	if resource.update(advance: params[:advance])
            redirect_back fallback_location: root_path, notice: "Success! Advance Added!" 
        else
            redirect_back fallback_location: root_path, notice: "Error!" 
        end
    end

	action_item :rejected_with_pay, :only => :show do
	  	if (resource.status == "Pending Client Approval") && current_user.role != 'Individual Contributor'
	  		link_to 'Rejected with Pay', status_update_admin_client_task_path(resource.id, status: 'Rejected with Pay'), :id => 'accept_task_button'
		end
	end

	action_item :submit_task, :only => :show do
	  	if (resource.status == "In Progress" || resource.status == "In Revision") && current_user == resource.writer
	  		link_to 'Submit Task', edit_admin_client_task_path(resource.id, submit_task: true), :id => 'submit_task_button'
		end
	end

	filter :client
	filter :task_title
	filter :status
	filter :writer_id, as: :select, collection: User.all
	filter :due_date_time
	filter :team

	index do
		column do |v|
			link_to 'View', "client_tasks/#{v.id}"  
		end
		selectable_column
		column :client do |w|
			if current_user.is_writer?
				w.client.name
			else
				w.client
			end
		end
		column :team
		column :task_title
		column :due_date_time
        column :status do  |s|
			status_tag s.status
		end
		column :writer
	end
	
	sidebar 'Task Information', :only => :show do
    	attributes_table do
			row :task_title
			row :client do |w|
				if current_user.is_writer?
					w.client.name
				else
					w.client
				end
			end
			row :user
			row :required_word_count
			row :pay_rate if current_user.is_admin? || current_user.is_manager?
			row :team
			row :writer
			row :due_date_time
     		row  :instructions do |r|
        		r.instructions.nil? ? nil : link_to('View Instructions', r.get_instructions, target: :_blank)
      		end
    	end
  	end


  	show :title => :task_title do
     	panel 'Submission Details', only: :show do
        	attributes_table_for client_task do
        		row :status do  |s|
					status_tag s.status
				end
          		row :delivered_date
          		row :submitted_word_count
          		row  :submission do |r|
        			r.submission.nil? ? nil : link_to('View Submission', r.get_submission, target: :_blank)
      			end
      			row :revision_number
        	end
      	end

      	panel 'Payment Details', only: :show do
        	attributes_table_for client_task do
        		row :client_payment_due if current_user.is_admin? || current_user.is_manager?
				row :advance if current_user.is_admin? || current_user.is_manager?
        		row :client_payment_status if current_user.is_admin? || current_user.is_manager?
				row :payment_type if current_user.is_admin? || current_user.is_manager?
        		row :manager_payment_due  if current_user.is_admin? || current_user.is_manager?
        		row :manager_payment_status if current_user.is_admin? || current_user.is_manager?
        		row :writer_payment_due
      			row :writer_payment_status
        	end
      	end
      	panel 'Performance Details', only: :show do
        	attributes_table_for client_task do
          		row :task_accepted_date_stamp
          		row :task_submitted_date_stamp
      			row :task_revision_date_stamp
				row :revision_due_date
				row :revision_submission_date
      			row :approved_rejected_date_stamp
        	end
      	end
      	active_admin_comments
    end
end