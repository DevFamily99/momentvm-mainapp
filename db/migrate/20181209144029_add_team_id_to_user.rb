class AddTeamIdToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :team_id, :bigint
  end
end
