class AddPaymentTypeToClientInvoice < ActiveRecord::Migration[6.1]
  def change
    add_column :client_invoices, :payment_type, :string, default: "Submitted Word Count"
    add_column :client_tasks, :payment_type, :string, default: "Submitted Word Count"
  end
end
