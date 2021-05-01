ActiveAdmin.register ClientInvoice do
    menu parent: 'Invoices', if: proc{ current_user.is_manager? || current_user.is_admin?  }
    actions :show, :index

    scope :pending, if: proc{ current_user.is_admin?  }
    scope :paid, if: proc{ current_user.is_admin?  }
    scope("My Client Pending Invoices", default: true, if: proc{ current_user.is_manager?}) { |scope| scope.where(user: current_user.id, status: "Due")}
    scope("My Client Invoices", if: proc{ current_user.is_manager?}) { |scope| scope.where(user: current_user.id)}

    filter :client
    filter :user
    filter :status, as: :select, collection: AppConstant::PAYMENT_STATUS, include_blank: true

    action_item :print_invoice, :only => :show do
         link_to 'Print Invoice', 'your_link_here', :onclick => 'window.print();return false;'
    end

  member_action :pay_invoice do
    resource.client_invoice_tasks.each do |t|
        t.client_task.update!(client_payment_status:'Paid')
    end
    resource.update!(status:'Paid')

    flash[:error] = 'Invoice Has Been Paid!'
    redirect_back fallback_location: root_path
 end

    action_item :mark_paid, :only => :show do 
        link_to 'Mark As Paid', pay_invoice_admin_client_invoice_path(resource.id) if resource.status != "Paid"
   end

    show do 
        render :partial => 'invoice'
     end

     form do 
        render :partial => 'form'
     end

     index do
        actions
		column :client
        column :status do |s|
            status_tag (s.status)
        end
        column :user
        column :invoice_created_date
        column :total_amount
     end
end