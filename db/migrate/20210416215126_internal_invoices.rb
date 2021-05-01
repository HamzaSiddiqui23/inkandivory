class InternalInvoices < ActiveRecord::Migration[6.1]
  def change
    create_table :internal_invoices do |t|
      t.date    :invoice_created_date
      t.string  :status
      t.integer :manager_total
      t.integer :writer_total
      t.integer :client_total
      t.integer :user_id, :refrences => :users
    end
  end
end
