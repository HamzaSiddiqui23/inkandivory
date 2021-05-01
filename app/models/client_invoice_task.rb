class ClientInvoiceTask < ApplicationRecord
	belongs_to :client_invoice
    belongs_to :client_task
end
