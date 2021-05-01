class InternalInvoiceTasks < ActiveRecord::Migration[6.1]
  def change
    create_table :internal_invoice_tasks do |t|
      t.integer :internal_invoice_id, :refrences => :internal_invoices
      t.integer :client_task_id, :refrences => :client_tasks
    end
  end
end
