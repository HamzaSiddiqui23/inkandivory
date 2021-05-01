class AddBonusToInternalInvoice < ActiveRecord::Migration[6.1]
  def change
    change_table :internal_invoices do |t|
      t.integer :bonus
    end
  end
end
