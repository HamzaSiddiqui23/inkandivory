class InternalInvoice < ApplicationRecord
    has_many :internal_invoice_tasks
    belongs_to :user

    scope :paid, lambda { where(status: 'Paid') }
    scope :pending, lambda { where.not(status: 'Paid') }

    def notify_paid_invoice
        Slack.configure do |config|
            config.token = ENV['SLACK_TOKEN']
            raise 'Missing ENV[SLACK_TOKEN]!' unless config.token
          end
          client = Slack::Web::Client.new
          client.auth_test
          u = user
          client.chat_postMessage(channel: u.slack_id, text: "\n :bell: Your <http://127.0.0.1:3000/admin/internal_invoices/#{id}|Invoice> has been Paid! :moneybag: \n")
    end

end
