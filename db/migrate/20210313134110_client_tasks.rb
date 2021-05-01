class ClientTasks < ActiveRecord::Migration[6.1]
  def change
  	create_table   :client_tasks do |t|
  		t.integer  :client_id, 	:refrences => :clients   
  		t.string   :task_title
  		t.integer  :required_word_count
  		t.float    :pay_rate
  		t.integer  :writer_id, :refrences => :users
  		t.datetime :due_date_time
  		t.string   :details
  		t.datetime :delivered_date
  		t.integer  :submitted_word_count
  		t.string   :submission
  		t.binary   :submission_file
  		t.string   :instructions
  		t.binary   :instructions_file
      t.datetime :task_accepted_date_stamp
      t.datetime :task_submitted_date_stamp
      t.datetime :task_revision_date_stamp
      t.datetime :approved_rejected_date_stamp
      t.integer  :revision_number, :default => 0
      t.string   :status
      t.string   :client_payment_status
      t.string   :writer_payment_status
      t.string   :manager_payment_status
      t.integer  :client_payment_due
      t.integer  :writer_payment_due
      t.integer  :manager_payment_due
  		t.timestamps
  	end
  end
end
