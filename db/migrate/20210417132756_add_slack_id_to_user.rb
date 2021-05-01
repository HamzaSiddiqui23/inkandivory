class AddSlackIdToUser < ActiveRecord::Migration[6.1]
  def change
    change_table :users do |t|
      t.string :slack_id
    end
  end
end
