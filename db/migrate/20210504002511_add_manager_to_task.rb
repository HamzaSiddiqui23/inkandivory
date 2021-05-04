class AddManagerToTask < ActiveRecord::Migration[6.1]
  def change
    add_column :client_tasks, :user_id, :integer, :refrences => :users
  end
end
