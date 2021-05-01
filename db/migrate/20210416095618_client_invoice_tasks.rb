class ClientInvoiceTasks < ActiveRecord::Migration[6.1]
  def change
    create_table :client_invoice_tasks do |t|
      t.integer :client_invoice_id, :refrences => :client_invoices
      t.integer :client_task_id, :refrences => :client_tasks
    end
  end
end
