class AddAdvanceToClientTask < ActiveRecord::Migration[6.1]
  def change
    add_column :client_tasks, :advance, :integer, default: 0
    add_column :client_invoices, :advance, :integer, default: 0
  end
end
