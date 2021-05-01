class ClientInvoice < ApplicationRecord
	belongs_to :client
    has_many :client_invoice_tasks
    belongs_to :user

    scope :paid, lambda { where(status: 'Paid') }
    scope :pending, lambda { where.not(status: 'Paid') }

end
