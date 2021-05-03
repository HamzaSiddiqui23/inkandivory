ActiveAdmin.register InternalInvoice do
    menu parent: 'Invoices', if: proc{ current_user.is_manager? || current_user.is_admin?  }
    actions :show, :index

    scope :pending, if: proc{ current_user.is_admin?  }
    scope :paid, if: proc{ current_user.is_admin?  }
    scope("My Pending Invoices", default: true, if: proc{ current_user.is_manager?}) { |scope| scope.where(user: current_user.id, status: "Due")}
    scope("My Invoices", if: proc{ current_user.is_manager?}) { |scope| scope.where(user: current_user.id)}
    scope("My Team Invoices",if: proc{ current_user.is_manager?}) { |scope| scope.where(user: User.where(manager_id: current_user.id))}
    scope("My Team Pending Invoices",if: proc{ current_user.is_manager?}) { |scope| scope.where( status: "Due", user: User.where(manager_id: current_user.id))}
    filter :user
    filter :status, as: :select, collection: AppConstant::PAYMENT_STATUS, include_blank: true

    RESTRICTED_ACTIONS = ["edit", "update"]

    controller do
		def action_methods
		  if current_user.is_admin? || current_user.is_manager?
			super
		  else
			super - RESTRICTED_ACTIONS
		  end
		end
	  end


    action_item :print_invoice, :only => :show do
         link_to 'Print Invoice', 'your_link_here', :onclick => 'window.print();return false;'
    end

    member_action :add_bonus do 
        if resource.update(bonus: params[:bonus])
            redirect_back fallback_location: root_path, notice: "Success! Bonus Added!" 
        else
            redirect_back fallback_location: root_path, notice: "Error!" 
        end
    end

    action_item :add_bonus_button, :only => :show do
        link_to 'Add Bonus', add_bonus_admin_internal_invoice_path, :id => 'bonus_button'
   end

    
  member_action :pay_invoice do
    if resource.manager_total.nil?
        resource.internal_invoice_tasks.each do |t|
            t.client_task.update(writer_payment_status: "Paid")
        end
        resource.notify_paid_invoice
    else
        resource.internal_invoice_tasks.each do |t|
            t.client_task.update(manager_payment_status: "Paid")
        end
        resource.notify_paid_invoice
    end
    resource.update!(status:'Paid')

    flash[:error] = 'Invoice Has Been Paid!'
    redirect_back fallback_location: root_path
 end

    action_item :mark_paid, :only => :show do 
        if current_user.is_admin?
            link_to 'Mark As Paid', pay_invoice_admin_internal_invoice_path(resource.id) if resource.status != "Paid" 
        end
   end

    show do 
        render :partial => 'invoice'
     end

     index do
        column do |v|
			link_to 'View', "internal_invoices/#{v.id}"  
		end
        column :status do |s|
            status_tag (s.status)
        end
        column :user
        column :invoice_created_date
        column :writer_total
        column :manager_total
     end
end