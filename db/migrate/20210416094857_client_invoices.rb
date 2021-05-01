class ClientInvoices < ActiveRecord::Migration[6.1]
  def change
    create_table :client_invoices do |t|
      t.date    :invoice_created_date
      t.string  :status
      t.string  :client_id, 	:refrences => :clients
      t.integer :total_amount
      t.integer :user_id, :refrences => :users
    end
  end
end
