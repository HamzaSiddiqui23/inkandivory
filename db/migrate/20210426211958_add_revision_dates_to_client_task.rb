class AddRevisionDatesToClientTask < ActiveRecord::Migration[6.1]
  def change
    change_table :client_tasks do |t|
      t.datetime :revision_due_date
      t.datetime :revision_submission_date
    end
  end
end
