class InternalInvoiceTask < ApplicationRecord
	belongs_to :internal_invoice
    belongs_to :client_task
end
